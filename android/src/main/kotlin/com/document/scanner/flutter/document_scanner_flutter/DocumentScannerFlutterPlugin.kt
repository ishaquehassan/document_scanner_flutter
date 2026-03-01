package com.document.scanner.flutter.document_scanner_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.util.*
import com.scanlibrary.ScanActivity
import com.scanlibrary.ScanConstants


/** DocumentScannerFlutterPlugin */
class DocumentScannerFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var call: MethodCall

    /// For activity binding
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var result: Result? = null

    /// For scanner library
    companion object {
        val SCAN_REQUEST_CODE: Int = 101
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
            "camera" -> {
                camera()
            }
            "gallery" -> {
                gallery()
            }
            else -> {
                result.notImplemented()
            }
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

    private fun composeIntentArguments(intent:Intent) = mapOf(
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
    ).entries.filter { call.hasArgument(it.value) && call.argument<String>(it.value) != null }.forEach {
        intent.putExtra(it.key,  call.argument<String>(it.value))
    }

    private fun camera() {
        activityPluginBinding?.activity?.apply {
            val intent = Intent(this, ScanActivity::class.java)
            intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE,  ScanConstants.OPEN_CAMERA)
            composeIntentArguments(intent)
            startActivityForResult(intent, SCAN_REQUEST_CODE)
        }
    }

    private fun gallery() {
        activityPluginBinding?.activity?.apply {
            val intent = Intent(this, ScanActivity::class.java)
            intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, ScanConstants.OPEN_MEDIA)
            composeIntentArguments(intent)
            startActivityForResult(intent, SCAN_REQUEST_CODE)
        }
    }

    fun getRealPathFromUri(context: Context, contentUri: Uri?): String? {
        if (contentUri == null) return null

        // Android 10+ (API 29+): use ContentResolver stream to copy to temp file
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return try {
                val inputStream = context.contentResolver.openInputStream(contentUri) ?: return null
                val tempFile = File.createTempFile("scan_", ".jpg", context.cacheDir)
                tempFile.outputStream().use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        // React to activity result and if request code == ResultActivity.REQUEST_CODE
        return when (resultCode) {
            Activity.RESULT_OK -> {
                if (requestCode == SCAN_REQUEST_CODE) {
                    activityPluginBinding?.activity?.apply {
                        val uri = data?.extras?.getParcelable<Uri>(ScanConstants.SCANNED_RESULT)
                        if (uri != null) {
                            result?.success(getRealPathFromUri(activityPluginBinding!!.activity, uri))
                        } else {
                            result?.success(null)
                        }
                    }
                }
                true
            }
            else -> false
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}


}
