// 类型定义文件

export type Status = 'active' | 'inactive' | 'pending';

export interface Product {
  id: number;
  name: string;
  price: number;
  status: Status;
  tags?: string[];
}

// 有问题的类型定义
export interface Order {
  id; // 缺少类型
  products: Product[];
  total: number;
  customerInfo: any; // 应该避免使用any
  createdAt: Date;
}

// 泛型使用示例
export interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
}

// 枚举定义
export enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  GUEST = 'guest',
}
