package com.document.scanner.flutter.document_scanner_flutter

import android.app.Activity
import android.app.ActivityOptions
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.os.StrictMode
import android.provider.MediaStore
import android.util.Log
import android.view.View
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
//import com.scanlibrary.ScanActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList
import android.R.attr.data
import android.content.Context
import android.database.Cursor
import androidx.core.net.toFile
import com.scanlibrary.ScanActivity
import com.scanlibrary.ScanConstants


/** DocumentScannerFlutterPlugin */
class DocumentScannerFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    /// For activity binding
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var result: Result? = null

    /// For scanner library
    companion object {
        val SCAN_REQUEST_CODE: Int = 101
    }

    lateinit var mCurrentPhotoPath: String
    private val scannedBitmaps: ArrayList<Uri> = ArrayList()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "document_scanner_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        this.result = result
        if (call.method == "scan") {
            scan()
        } else {
            result.notImplemented()
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

    private fun scan() {
        activityPluginBinding?.activity?.apply {
            val intent = Intent(this, ScanActivity::class.java)
            intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, ScanConstants.OPEN_INTENT_PREFERENCE)
            startActivityForResult(intent, SCAN_REQUEST_CODE)
        }
    }

    fun getRealPathFromUri(context: Context, contentUri: Uri?): String? {
        var cursor: Cursor? = null
        return try {
            val proj = arrayOf(MediaStore.Images.Media.DATA)
            cursor = context.getContentResolver().query(contentUri!!, proj, null, null, null)
            val column_index: Int = cursor!!.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            cursor.moveToFirst()
            cursor.getString(column_index)
        } finally {
            if (cursor != null) {
                cursor.close()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        // React to activity result and if request code == ResultActivity.REQUEST_CODE
        return when (resultCode) {
            Activity.RESULT_OK -> {
                if (requestCode == SCAN_REQUEST_CODE) {
                    activityPluginBinding?.activity?.apply {
                        val uri = data!!.extras!!.getParcelable<Uri>(ScanConstants.SCANNED_RESULT)
                        println(uri)
                        result?.success(getRealPathFromUri(activityPluginBinding!!.activity,uri))
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
