package com.example.androidtestdemo

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.TextView
import android.util.Log

class MainActivity : AppCompatActivity() {
    
    private val unusedVariable = "This is unused"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val textView = TextView(this)
        textView.text = "Hello World"
        
        val message="Welcome to Android"
        val count=10
        
        Log.d("MainActivity", "Debug message: $message")
        
        for(i in 0..100){
            val obj = Object()
        }
        
        setupView()
    }
    
    private fun setupView() {
        val title   =   getString(R.string.app_name)
        val version=   "1.0"
        
        val info = "App: " + title + " Version: " + version
        
        Log.i("Info", info)
    }
    
    private fun unusedFunction(): String {
        return "This function is never called"
    }
    
    fun handleNullableString(input: String?) {
        val length = input!!.length
    }
    
    companion object {
        const val max_count = 100
        
        fun logMessage(msg: String) {
            Log.v("MainActivity", msg)
        }
    }
} 