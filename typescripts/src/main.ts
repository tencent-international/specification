import { createUser, processUsers, User } from './index';
import { Calculator, formatCurrency } from './utils';
import { Product, UserRole, Status } from './types';

// 测试用户功能
const user1 = createUser(1, 'Alice', 'alice@example.com');
const user2 = createUser(2, 'Bob');

const users = [user1, user2];
const activeUsers = processUsers(users);

console.log('Active users:', activeUsers);

// 测试计算器
const calc = new Calculator(10);
calc.add(5).multiply(2);
console.log('Calculator result:', calc.getValue());

// 测试格式化
const price = formatCurrency(99.99, 'USD');
console.log('Formatted price:', price);

// 测试产品数据
const product: Product = {
  id: 1,
  name: 'Laptop',
  price: 999.99,
  status: 'active' as Status,
  tags: ['electronics', 'computer'],
};

console.log('Product:', product);
console.log('User role:', UserRole.ADMIN);
