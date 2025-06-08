// 类型定义文件

export type Status = 'active' | 'inactive' | 'pending';

export interface Product {
  id: number;
  name: string;
  price: number;
  status: Status;
  tags?: string[];
}

// 修复后的类型定义
export interface CustomerInfo {
  name: string;
  email: string;
  phone?: string;
}

export interface Order {
  id: number; // 添加了类型
  products: Product[];
  total: number;
  customerInfo: CustomerInfo; // 使用具体类型替代any
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
