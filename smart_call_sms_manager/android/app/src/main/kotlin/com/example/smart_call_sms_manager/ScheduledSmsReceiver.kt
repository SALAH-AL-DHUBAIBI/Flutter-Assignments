package com.example.smart_call_sms_manager

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsManager
import android.widget.Toast
import android.util.Log

class ScheduledSmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val number = intent.getStringExtra("number")
        val message = intent.getStringExtra("message")
        
        if (number != null && message != null) {
            try {
                val smsManager = SmsManager.getDefault()
                smsManager.sendTextMessage(number, null, message, null, null)
                Log.d("SmartManager", "Scheduled SMS sent to $number")
            } catch (e: Exception) {
                Log.e("SmartManager", "Failed to send scheduled SMS: ${e.message}")
            }
        }
    }
}
