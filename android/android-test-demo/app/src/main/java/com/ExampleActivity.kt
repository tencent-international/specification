package com

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

/**
 * 示例 Activity - 展示代码规范
 */
class ExampleActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 示例：符合 Kotlin 代码规范
        val message = getString(R.string.app_name)
        setupViews(message)
    }
    
    private fun setupViews(title: String) {
        // 代码实现
        supportActionBar?.title = title
    }
    
    companion object {
        private const val TAG = "ExampleActivity"
    }
}
