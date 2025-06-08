// 工具函数文件 - 包含多种代码问题

export class Calculator {
  private value: number;

  constructor(initialValue) {
    this.value = initialValue || 0;
  }

  add(num) {
    this.value += num;
    return this;
  }

  multiply(num) {
    this.value *= num;
    return this;
  }

  getValue() {
    return this.value;
  }

  // 错误的类型使用
  divide(divisor: any): any {
    if (divisor === 0) {
      throw new Error('Cannot divide by zero');
    }
    this.value = this.value / divisor;
    return this;
  }
}

// 格式问题的函数
export function formatCurrency(amount, currency = 'USD') {
  if (typeof amount !== 'number') {
    return 'Invalid amount';
  }
  return `${currency} ${amount.toFixed(2)}`;
}

// 缺少类型的数组操作
export function filterEvenNumbers(numbers) {
  return numbers.filter(function (num) {
    return num % 2 === 0;
  });
}

// 使用var而不是const/let
export function oldStyleFunction() {
  var message = 'Hello World';
  var count = 0;
  for (var i = 0; i < 10; i++) {
    count++;
  }
  return message + ' ' + count;
}
