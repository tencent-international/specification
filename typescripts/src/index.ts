// 这是一个测试文件，包含各种代码问题用于测试lint和format功能

export interface User {
  id: number;
  name: string;
  email?: string;
  isActive: boolean;
}

export function createUser(id, name, email) {
  var user = {
    id: id,
    name: name,
    email: email || null,
    isActive: true,
  };
  return user;
}

export function processUsers(users: any[]) {
  let result = [];
  for (let i = 0; i < users.length; i++) {
    let user = users[i];
    if (user.isActive == true) {
      result.push(user.name.toUpperCase());
    }
  }
  return result;
}

// 未使用的变量
const unusedVariable = 'this will trigger eslint error';

// 没有返回类型声明的函数
export function calculateAge(birthYear) {
  const currentYear = new Date().getFullYear();
  return currentYear - birthYear;
}

// 使用any类型
export function handleData(data: any): any {
  return data.someProperty;
}
