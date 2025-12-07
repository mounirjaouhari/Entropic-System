import axios, { AxiosInstance } from 'axios';

// Types for Order API
export interface Order {
  id: string;
  userId: string;
  status: 'pending' | 'processing' | 'completed' | 'cancelled';
  totalAmount: number;
  items: OrderItem[];
  createdAt: string;
  updatedAt: string;
  shippingAddress?: Address;
  paymentMethod?: string;
}

export interface OrderItem {
  id: string;
  productId: string;
  quantity: number;
  price: number;
  subtotal: number;
}

export interface Address {
  street: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
}

export interface CreateOrderDto {
  items: OrderItem[];
  shippingAddress: Address;
  paymentMethod: string;
}

export interface UpdateOrderDto {
  status?: 'pending' | 'processing' | 'completed' | 'cancelled';
  shippingAddress?: Address;
  paymentMethod?: string;
}

export interface OrdersResponse {
  data: Order[];
  total: number;
  page: number;
  limit: number;
}

/**
 * Orders API Service
 * Provides methods for managing orders with CRUD operations
 */
class OrdersService {
  private apiClient: AxiosInstance;
  private baseUrl: string;

  constructor(baseUrl: string = process.env.REACT_APP_API_URL || 'http://localhost:3000/api') {
    this.baseUrl = baseUrl;
    this.apiClient = axios.create({
      baseURL: `${baseUrl}/orders`,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add request interceptor to include auth token
    this.apiClient.interceptors.request.use((config) => {
      const token = localStorage.getItem('authToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });
  }

  /**
   * Retrieve all orders with optional pagination and filtering
   * @param page - Page number (default: 1)
   * @param limit - Items per page (default: 10)
   * @param status - Optional status filter
   * @returns Promise containing orders list and pagination info
   */
  async getAllOrders(
    page: number = 1,
    limit: number = 10,
    status?: string
  ): Promise<OrdersResponse> {
    try {
      const params: Record<string, any> = { page, limit };
      if (status) {
        params.status = status;
      }

      const response = await this.apiClient.get<OrdersResponse>('/', { params });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Retrieve a single order by ID
   * @param orderId - Order ID
   * @returns Promise containing order details
   */
  async getOrderById(orderId: string): Promise<Order> {
    try {
      const response = await this.apiClient.get<Order>(`/${orderId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Retrieve all orders for the current user
   * @param page - Page number (default: 1)
   * @param limit - Items per page (default: 10)
   * @returns Promise containing user's orders
   */
  async getUserOrders(page: number = 1, limit: number = 10): Promise<OrdersResponse> {
    try {
      const response = await this.apiClient.get<OrdersResponse>('/my-orders', {
        params: { page, limit },
      });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Create a new order
   * @param orderData - Order creation data
   * @returns Promise containing the created order
   */
  async createOrder(orderData: CreateOrderDto): Promise<Order> {
    try {
      const response = await this.apiClient.post<Order>('/', orderData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Update an existing order
   * @param orderId - Order ID to update
   * @param updateData - Partial order data to update
   * @returns Promise containing the updated order
   */
  async updateOrder(orderId: string, updateData: UpdateOrderDto): Promise<Order> {
    try {
      const response = await this.apiClient.patch<Order>(`/${orderId}`, updateData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Delete an order
   * @param orderId - Order ID to delete
   * @returns Promise with deletion confirmation
   */
  async deleteOrder(orderId: string): Promise<{ message: string }> {
    try {
      const response = await this.apiClient.delete<{ message: string }>(`/${orderId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Cancel an order
   * @param orderId - Order ID to cancel
   * @returns Promise containing the updated order
   */
  async cancelOrder(orderId: string): Promise<Order> {
    try {
      const response = await this.apiClient.patch<Order>(`/${orderId}/cancel`, {});
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get order status
   * @param orderId - Order ID
   * @returns Promise containing order status
   */
  async getOrderStatus(orderId: string): Promise<{ status: string; updatedAt: string }> {
    try {
      const response = await this.apiClient.get<{ status: string; updatedAt: string }>(
        `/${orderId}/status`
      );
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Export orders as CSV
   * @param params - Optional filters for export
   * @returns Promise with CSV blob
   */
  async exportOrdersAsCSV(params?: Record<string, any>): Promise<Blob> {
    try {
      const response = await this.apiClient.get<Blob>('/export/csv', {
        params,
        responseType: 'blob',
      });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Centralized error handling
   * @param error - The error object
   * @returns A formatted error message
   */
  private handleError(error: any): Error {
    if (axios.isAxiosError(error)) {
      const message = error.response?.data?.message || error.message || 'An error occurred';
      const status = error.response?.status;

      if (status === 401) {
        // Handle unauthorized
        localStorage.removeItem('authToken');
        window.location.href = '/login';
      }

      return new Error(`[${status}] ${message}`);
    }
    return error instanceof Error ? error : new Error(String(error));
  }

  /**
   * Set a new authorization token
   * @param token - Auth token
   */
  setAuthToken(token: string): void {
    localStorage.setItem('authToken', token);
    this.apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }

  /**
   * Remove authorization token
   */
  clearAuthToken(): void {
    localStorage.removeItem('authToken');
    delete this.apiClient.defaults.headers.common['Authorization'];
  }
}

// Export singleton instance
export default new OrdersService();
