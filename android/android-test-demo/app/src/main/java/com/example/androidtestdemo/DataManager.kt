package com.example.androidtestdemo

import android.content.Context
import android.util.Log
import java.io.FileInputStream
import java.io.IOException

// 数据管理类 - 包含各种代码问题

class DataManager(private val context: Context) {
    
    // 变量命名不规范
    private var user_count = 0
    private var MAX_SIZE = 1000
    
    // 缺少返回类型注解
    fun loadData() {
        // 资源泄漏问题
        val inputStream = FileInputStream("data.txt")
        // 未关闭stream - Recycle警告
        
        // 格式问题
        val data=HashMap<String,String>()
        data.put("key1","value1")
        data.put("key2","value2")
        
        // 不应该在这里做日志
        Log.w("DataManager","Loading data...")
    }
    
    // 空的catch块
    fun saveData(data: String) {
        try {
            // 一些操作
            processData(data)
        } catch (e: IOException) {
            // 空的catch块 - 安全问题
        }
    }
    
    private fun processData(data: String) {
        // 字符串比较问题
        if (data == "admin") {  // 应该使用equals
            Log.d("Access", "Admin user detected")
        }
        
        // 格式问题：空格
        val result=data.trim()+"-processed"
        user_count++
    }
    
    // 返回类型可以推断但最好明确
    fun getUserCount() = user_count
    
    // 未使用的参数
    fun updateSettings(setting: String, unused: Int) {
        Log.i("Settings", "Updated: $setting")
        // unused 参数没有被使用
    }
    
    // 过长的函数，应该拆分
    fun complexOperation(input: String): String {
        val step1 = input.trim()
        val step2 = step1.lowercase()
        val step3 = step2.replace(" ", "_")
        val step4 = step3.substring(0, minOf(step3.length, 10))
        val step5 = "${step4}_processed"
        val step6 = step5.uppercase()
        val step7 = step6.replace("_", "-")
        val step8 = "${step7}_final"
        
        // 更多处理...
        Log.v("Process", "Completed complex operation")
        return step8
    }
    
    companion object {
        // 常量应该在顶部
        private const val TAG = "DataManager"
        
        // 静态方法中使用硬编码字符串
        fun getVersion(): String {
            return "1.0.0"  // 应该从资源或配置读取
        }
    }
} 