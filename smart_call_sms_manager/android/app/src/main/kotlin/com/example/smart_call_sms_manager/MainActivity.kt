package com.example.smart_call_sms_manager

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.CallLog
import android.provider.Telephony
import android.telecom.TelecomManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.telephony.SmsManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.smart_manager/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestDefaultDialerRole" -> {
                    requestDefaultDialer()
                    result.success(true)
                }
                "requestDefaultSmsRole" -> {
                    requestDefaultSms()
                    result.success(true)
                }
                "makeDirectCall" -> {
                    val number = call.argument<String>("number")
                    if (number != null) {
                        makeDirectCall(number)
                        result.success(true)
                    } else {
                        result.error("INVALID_NUMBER", "Number is null", null)
                    }
                }
                "sendDirectSms" -> {
                    val number = call.argument<String>("number")
                    val message = call.argument<String>("message")
                    if (number != null && message != null) {
                        sendDirectSms(number, message)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Number or message is null", null)
                    }
                }
                "getCallLogs" -> {
                    val logs = getCallLogs()
                    result.success(logs)
                }
                "getSmsConversations" -> {
                    val threads = getSmsConversations()
                    result.success(threads)
                }
                "getSmsMessages" -> {
                    val address = call.argument<String>("address")
                    if (address != null) {
                        val messages = getSmsMessages(address)
                        result.success(messages)
                    } else {
                        result.error("ARGS", "Address required", null)
                    }
                }
                "getContactName" -> {
                    val number = call.argument<String>("number")
                    if (number != null) {
                        val name = getContactName(number)
                        result.success(name)
                    } else {
                         result.success(null)
                    }
                }
                "scheduleSms" -> {
                    val number = call.argument<String>("number")
                    val message = call.argument<String>("message")
                    val time = call.argument<Long>("time")
                    
                    if (number != null && message != null && time != null) {
                        scheduleSms(number, message, time)
                        result.success(true)
                    } else {
                        result.error("ARGS", "Missing args", null)
                    }
                }
                "markMessagesAsRead" -> {
                    val threadId = call.argument<String>("threadId")
                    if (threadId != null) {
                        markMessagesAsRead(threadId)
                        result.success(true)
                    } else {
                        result.error("ARGS", "ThreadId required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleSms(number: String, message: String, time: Long) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, ScheduledSmsReceiver::class.java).apply {
            putExtra("number", number)
            putExtra("message", message)
        }
        
        // Unique RequestCode based on time to allow multiple
        val requestCode = (time % 100000).toInt()
        
        val pendingIntent = PendingIntent.getBroadcast(
            this, 
            requestCode, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, time, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, time, pendingIntent)
        }
    }

    // ... existing roles/direct methods ...
    private fun requestDefaultDialer() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
            startActivityForResult(intent, 1)
        } else {
             val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
             intent.putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
             startActivity(intent)
        }
    }

    private fun requestDefaultSms() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
            intent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, packageName)
            startActivity(intent)
        }
    }

    private fun makeDirectCall(number: String) {
        val uri = Uri.parse("tel:$number")
        val intent = Intent(Intent.ACTION_CALL, uri)
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {
            startActivity(intent)
        }
    }

    private fun sendDirectSms(number: String, message: String) {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED) {
            val smsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(number, null, message, null, null)
        }
    }

    private fun getCallLogs(): List<Map<String, String>> {
        val logs = mutableListOf<Map<String, String>>()
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_CALL_LOG) != PackageManager.PERMISSION_GRANTED) {
            return logs
        }
        // ... (Keep existing simple one or fetch names here?)
        // Better to fetch names on UI side or basic here. Let's keep specific query separate to avoid slow queries.
        val cursor = contentResolver.query(
            CallLog.Calls.CONTENT_URI,
            null, null, null, CallLog.Calls.DATE + " DESC LIMIT 50"
        )
        cursor?.use {
            val numberIndex = it.getColumnIndex(CallLog.Calls.NUMBER)
            val typeIndex = it.getColumnIndex(CallLog.Calls.TYPE)
            val dateIndex = it.getColumnIndex(CallLog.Calls.DATE)
            val nameIndex = it.getColumnIndex(CallLog.Calls.CACHED_NAME) // Try cached name

            while (it.moveToNext()) {
                val number = it.getString(numberIndex)
                val type = it.getInt(typeIndex)
                val date = it.getLong(dateIndex)
                val cachedName = if (nameIndex != -1) it.getString(nameIndex) else null
                
                logs.add(mapOf(
                    "number" to number,
                    "type" to type.toString(),
                    "date" to date.toString(),
                    "name" to (cachedName ?: "")
                ))
            }
        }
        return logs
    }

    // New: Get Conversations (Unique Threads)
    // Optimized to get unread counts in single query
    private fun getSmsConversations(): List<Map<String, String>> {
        val threads = mutableListOf<Map<String, String>>()
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
            return threads
        }

        val seenThreads = mutableSetOf<String>()
        
        // First, get unread counts by thread_id
        val unreadCounts = mutableMapOf<String, Int>()
        val unreadCursor = contentResolver.query(
            Uri.parse("content://sms/inbox"),
            arrayOf("thread_id", "_id"),
            "read = 0",
            null,
            null
        )
        
        unreadCursor?.use {
            val threadIndex = it.getColumnIndex("thread_id")
            while (it.moveToNext()) {
                val threadId = it.getString(threadIndex)
                if (threadId != null) {
                    unreadCounts[threadId] = (unreadCounts[threadId] ?: 0) + 1
                }
            }
        }

        // Query ALL messages sorted by date DESC
        val cursor = contentResolver.query(
            Uri.parse("content://sms/"), 
            arrayOf("address", "body", "date", "thread_id"),
            null, 
            null,
            "date DESC" 
        )

        cursor?.use {
            val addrIndex = it.getColumnIndex("address")
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")
            val threadIndex = it.getColumnIndex("thread_id")

            while (it.moveToNext()) {
                val threadId = it.getString(threadIndex)
                if (threadId != null && !seenThreads.contains(threadId)) {
                    seenThreads.add(threadId)
                    val address = it.getString(addrIndex)
                    val body = it.getString(bodyIndex)
                    val date = it.getLong(dateIndex)
                    
                    // Get unread count from our pre-fetched map using thread_id
                    val unreadCount = unreadCounts[threadId] ?: 0
                    
                    threads.add(mapOf(
                        "thread_id" to threadId,
                        "address" to (address ?: ""),
                        "snippet" to (body ?: ""),
                        "date" to date.toString(),
                        "unread_count" to unreadCount.toString()
                    ))
                }
            }
        }
        return threads
    }

    // New: Get Messages for Thread
    private fun getSmsMessages(address: String): List<Map<String, String>> {
        val messages = mutableListOf<Map<String, String>>()
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
            return messages
        }

        val cursor = contentResolver.query(
            Uri.parse("content://sms/"), // All (sent and received)
            null,
            "address = ?",
            arrayOf(address),
            "date ASC"
        )

        cursor?.use {
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")
            val typeIndex = it.getColumnIndex("type") // 1=Inbox, 2=Sent

            while (it.moveToNext()) {
                val body = it.getString(bodyIndex)
                val date = it.getLong(dateIndex)
                val type = it.getString(typeIndex)

                messages.add(mapOf(
                    "body" to (body ?: ""),
                    "date" to date.toString(),
                    "type" to (type ?: "1")
                ))
            }
        }
        return messages
    }
    
    // New: Contact Lookup
    private fun getContactName(phoneNumber: String): String? {
         if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED) {
            return null
        }
        val uri = Uri.withAppendedPath(android.provider.ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber))
        val cursor = contentResolver.query(uri, arrayOf(android.provider.ContactsContract.PhoneLookup.DISPLAY_NAME), null, null, null)
        
        var name: String? = null
        cursor?.use {
            if (it.moveToFirst()) {
                name = it.getString(it.getColumnIndex(android.provider.ContactsContract.PhoneLookup.DISPLAY_NAME))
            }
        }
        return name
    }

    // Mark all messages in a thread as read
    private fun markMessagesAsRead(threadId: String) {
        try {
            val values = android.content.ContentValues()
            values.put("read", 1)
            
            // Update by thread_id is much safer and standard
            contentResolver.update(
                Uri.parse("content://sms"),
                values,
                "thread_id = ? AND read = 0",
                arrayOf(threadId)
            )
        } catch (e: Exception) {
            // Silently fail
        }
    }
    
    // Deprecated simple inbox fetcher (replaced by conversations)
    private fun getSmsInbox(): List<Map<String, String>> {
        // ... kept or removed ... returning empty or delegated.
        // For backwards compat just calling conversations? No, keep it specific.
        return getSmsConversations() 
    }
}
