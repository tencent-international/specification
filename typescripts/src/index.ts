// 这是一个测试文件，现在已修复所有代码质量问题

export interface User {
  id: number;
  name: string;
  email?: string;
  isActive: boolean;
}

export function createUser(id: number, name: string, email?: string): User {
  const user: User = {
    id: id,
    name: name,
    isActive: true,
  };

  if (email) {
    user.email = email;
  }

  return user;
}

export function processUsers(users: User[]): string[] {
  const result: string[] = [];
  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    if (user && user.isActive === true) {
      result.push(user.name.toUpperCase());
    }
  }
  return result;
}

// 有返回类型声明的函数
export function calculateAge(birthYear: number): number {
  const currentYear = new Date().getFullYear();
  return currentYear - birthYear;
}

// 使用更具体的类型替代any
export function handleData(data: { someProperty: unknown }): unknown {
  return data.someProperty;
}
