package com.document.scanner.flutter.document_scanner_flutter

import android.app.Activity
import android.app.ProgressDialog
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import androidx.exifinterface.media.ExifInterface
import com.scanlibrary.ScanActivity
import com.scanlibrary.ScanConstants
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileOutputStream

/** DocumentScannerFlutterPlugin */
class DocumentScannerFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var call: MethodCall

    private var activityPluginBinding: ActivityPluginBinding? = null
    private var result: Result? = null

    companion object {
        const val SCAN_REQUEST_CODE: Int = 101
        private const val PREFS_NAME = "AppData"
        private const val PREFS_KEY_IMAGE_PATH = "imagePathDocumentScanner"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "document_scanner_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        this.call = call
        this.result = result

        when (call.method) {
            "camera" -> camera()
            "gallery" -> gallery()
            "retrieveLostData" -> retrieveLostData(result)
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.removeActivityResultListener(this)
        activityPluginBinding = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    // ─── Method Handlers ──────────────────────────────────────────────────────

    private fun camera() {
        val activity = activityPluginBinding?.activity ?: return
        val intent = Intent(activity, ScanActivity::class.java)
        intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, ScanConstants.OPEN_CAMERA)

        val initialImageBytes = call.argument<ByteArray>("INITIAL_IMAGE")
        if (initialImageBytes != null) {
            val loadingMessage = call.argument<String>("ANDROID_INITIAL_IMAGE_LOADING_MESSAGE") ?: "Loading..."
            val canBackToInitial = call.argument<Boolean>("CAN_BACK_TO_INITIAL") ?: true

            @Suppress("DEPRECATION")
            val progressDialog = ProgressDialog(activity).apply {
                setMessage(loadingMessage)
                setCancelable(false)
                show()
            }

            CoroutineScope(Dispatchers.Main).launch {
                try {
                    val rotationDegrees = withContext(Dispatchers.IO) {
                        getRotationDegreesFromByteArray(initialImageBytes)
                    }
                    val uri = withContext(Dispatchers.IO) {
                        saveImageToTempFile(activity, initialImageBytes, rotationDegrees)
                    }
                    progressDialog.dismiss()

                    if (uri != null) {
                        intent.putExtra(ScanConstants.INITIAL_IMAGE, uri.toString())
                        intent.putExtra(ScanConstants.CAN_BACK_TO_INITIAL, canBackToInitial)
                    }
                    composeIntentArguments(intent)
                    activity.startActivityForResult(intent, SCAN_REQUEST_CODE)
                } catch (e: Exception) {
                    progressDialog.dismiss()
                    Log.e("DocumentScanner", "Error processing initial image: ${e.message}")
                    composeIntentArguments(intent)
                    activity.startActivityForResult(intent, SCAN_REQUEST_CODE)
                }
            }
            return
        }

        composeIntentArguments(intent)
        activity.startActivityForResult(intent, SCAN_REQUEST_CODE)
    }

    private fun gallery() {
        val activity = activityPluginBinding?.activity ?: return
        val intent = Intent(activity, ScanActivity::class.java)
        intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, ScanConstants.OPEN_MEDIA)
        composeIntentArguments(intent)
        activity.startActivityForResult(intent, SCAN_REQUEST_CODE)
    }

    private fun retrieveLostData(result: Result) {
        val activity = activityPluginBinding?.activity
        if (activity == null) {
            result.success(null)
            return
        }
        val prefs = activity.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedPath = prefs.getString(PREFS_KEY_IMAGE_PATH, null)
        prefs.edit().remove(PREFS_KEY_IMAGE_PATH).apply()
        result.success(savedPath)
    }

    // ─── Activity Result ──────────────────────────────────────────────────────

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != SCAN_REQUEST_CODE) return false

        return when (resultCode) {
            Activity.RESULT_OK -> {
                val activity = activityPluginBinding?.activity ?: return true
                val uri = data?.extras?.getParcelable<Uri>(ScanConstants.SCANNED_RESULT)
                val realPath = if (uri != null) getRealPathFromUri(activity, uri) else null

                // Save for lost data recovery
                if (realPath != null) {
                    activity.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                        .edit().putString(PREFS_KEY_IMAGE_PATH, realPath).apply()
                }

                result?.success(realPath)
                result = null
                true
            }
            Activity.RESULT_CANCELED -> {
                result?.success(null)
                result = null
                false
            }
            else -> {
                result?.success(null)
                result = null
                false
            }
        }
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private fun composeIntentArguments(intent: Intent) = mapOf(
        ScanConstants.SCAN_NEXT_TEXT to "ANDROID_NEXT_BUTTON_LABEL",
        ScanConstants.SCAN_SAVE_TEXT to "ANDROID_SAVE_BUTTON_LABEL",
        ScanConstants.SCAN_ROTATE_LEFT_TEXT to "ANDROID_ROTATE_LEFT_LABEL",
        ScanConstants.SCAN_ROTATE_RIGHT_TEXT to "ANDROID_ROTATE_RIGHT_LABEL",
        ScanConstants.SCAN_ORG_TEXT to "ANDROID_ORIGINAL_LABEL",
        ScanConstants.SCAN_BNW_TEXT to "ANDROID_BMW_LABEL",
        ScanConstants.SCAN_SCANNING_MESSAGE to "ANDROID_SCANNING_MESSAGE",
        ScanConstants.SCAN_LOADING_MESSAGE to "ANDROID_LOADING_MESSAGE",
        ScanConstants.SCAN_APPLYING_FILTER_MESSAGE to "ANDROID_APPLYING_FILTER_MESSAGE",
        ScanConstants.SCAN_CANT_CROP_ERROR_TITLE to "ANDROID_CANT_CROP_ERROR_TITLE",
        ScanConstants.SCAN_CANT_CROP_ERROR_MESSAGE to "ANDROID_CANT_CROP_ERROR_MESSAGE",
        ScanConstants.SCAN_OK_LABEL to "ANDROID_OK_LABEL"
    ).entries
        .filter { call.hasArgument(it.value) && call.argument<String>(it.value) != null }
        .forEach { intent.putExtra(it.key, call.argument<String>(it.value)) }

    fun getRealPathFromUri(context: Context, contentUri: Uri?): String? {
        if (contentUri == null) return null

        // Android 10+ (API 29+): stream copy to avoid deprecated DATA column
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return try {
                val inputStream = context.contentResolver.openInputStream(contentUri) ?: return null
                val tempFile = File.createTempFile("scan_", ".jpg", context.cacheDir)
                tempFile.outputStream().use { inputStream.copyTo(it) }
                inputStream.close()
                tempFile.absolutePath
            } catch (e: Exception) {
                Log.e("DocumentScanner", "Error copying file: ${e.message}")
                null
            }
        }

        // Android 9 and below: legacy DATA column
        var cursor: Cursor? = null
        return try {
            val proj = arrayOf(MediaStore.Images.Media.DATA)
            cursor = context.contentResolver.query(contentUri, proj, null, null, null)
            val columnIndex = cursor?.getColumnIndexOrThrow(MediaStore.Images.Media.DATA) ?: return null
            cursor.moveToFirst()
            cursor.getString(columnIndex)
        } catch (e: Exception) {
            Log.e("DocumentScanner", "Error getting real path: ${e.message}")
            null
        } finally {
            cursor?.close()
        }
    }

    private fun getRotationDegreesFromByteArray(byteArray: ByteArray): Float {
        return try {
            ByteArrayInputStream(byteArray).use { inputStream ->
                val exif = ExifInterface(inputStream)
                val orientation = exif.getAttributeInt(
                    ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL
                )
                when (orientation) {
                    ExifInterface.ORIENTATION_ROTATE_270 -> 270f
                    ExifInterface.ORIENTATION_ROTATE_180 -> 180f
                    ExifInterface.ORIENTATION_ROTATE_90 -> 90f
                    else -> 0f
                }
            }
        } catch (e: Exception) {
            Log.e("DocumentScanner", "EXIF read error: ${e.message}")
            0f
        }
    }

    private fun saveImageToTempFile(context: Context, byteArray: ByteArray, rotationDegrees: Float): Uri? {
        return try {
            var bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size) ?: return null
            if (rotationDegrees != 0f) {
                val rotated = rotateBitmap(bitmap, rotationDegrees)
                bitmap.recycle()
                bitmap = rotated
            }
            val file = File(context.cacheDir, "scan_initial_${System.currentTimeMillis()}.jpg")
            FileOutputStream(file).use { bitmap.compress(Bitmap.CompressFormat.JPEG, 90, it) }
            bitmap.recycle()
            Uri.fromFile(file)
        } catch (e: Exception) {
            Log.e("DocumentScanner", "Error saving temp image: ${e.message}")
            null
        }
    }

    private fun rotateBitmap(source: Bitmap, angle: Float): Bitmap {
        val matrix = Matrix().apply { postRotate(angle) }
        return Bitmap.createBitmap(source, 0, 0, source.width, source.height, matrix, true)
    }
}
