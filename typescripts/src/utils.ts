// 工具函数文件 - 已修复所有代码问题

export class Calculator {
  private value: number;

  constructor(initialValue: number) {
    this.value = initialValue || 0;
  }

  add(num: number): Calculator {
    this.value += num;
    return this;
  }

  multiply(num: number): Calculator {
    this.value *= num;
    return this;
  }

  getValue(): number {
    return this.value;
  }

  // 修复后的类型使用
  divide(divisor: number): Calculator {
    if (divisor === 0) {
      throw new Error('Cannot divide by zero');
    }
    this.value = this.value / divisor;
    return this;
  }
}

// 修复格式问题的函数
export function formatCurrency(amount: number, currency = 'USD'): string {
  if (typeof amount !== 'number') {
    return 'Invalid amount';
  }
  return `${currency} ${amount.toFixed(2)}`;
}

// 添加了类型的数组操作
export function filterEvenNumbers(numbers: number[]): number[] {
  return numbers.filter(function (num: number): boolean {
    return num % 2 === 0;
  });
}

// 使用现代语法替代var
export function modernStyleFunction(): string {
  const message = 'Hello World';
  let count = 0;
  for (let i = 0; i < 10; i++) {
    count++;
  }
  return `${message} ${count}`;
}
