/**
 * Authentication API Service
 * Handles all authentication-related API calls
 * Created: 2025-12-07 05:26:08 UTC
 */

import axios, { AxiosInstance } from 'axios';

// API Base URL
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001/api';

// Create axios instance
const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Token storage keys
const ACCESS_TOKEN_KEY = 'accessToken';
const REFRESH_TOKEN_KEY = 'refreshToken';

/**
 * Interfaces for type safety
 */
export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterCredentials {
  email: string;
  password: string;
  confirmPassword: string;
  firstName?: string;
  lastName?: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data?: {
    accessToken: string;
    refreshToken: string;
    user: UserData;
  };
}

export interface UserData {
  id: string;
  email: string;
  firstName?: string;
  lastName?: string;
  createdAt: string;
  updatedAt: string;
}

export interface MeResponse {
  success: boolean;
  data: UserData;
}

export interface RefreshTokenResponse {
  success: boolean;
  data: {
    accessToken: string;
    refreshToken: string;
  };
}

/**
 * Auth Service Class
 */
class AuthService {
  /**
   * Set authorization header with access token
   */
  private setAuthHeader(token: string): void {
    if (token) {
      apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    } else {
      delete apiClient.defaults.headers.common['Authorization'];
    }
  }

  /**
   * Get stored access token
   */
  private getAccessToken(): string | null {
    return localStorage.getItem(ACCESS_TOKEN_KEY);
  }

  /**
   * Get stored refresh token
   */
  private getRefreshToken(): string | null {
    return localStorage.getItem(REFRESH_TOKEN_KEY);
  }

  /**
   * Store tokens in localStorage
   */
  private storeTokens(accessToken: string, refreshToken: string): void {
    localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
    localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
    this.setAuthHeader(accessToken);
  }

  /**
   * Clear all stored tokens
   */
  private clearTokens(): void {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    this.setAuthHeader('');
  }

  /**
   * Initialize - restore token from storage
   */
  public initialize(): void {
    const token = this.getAccessToken();
    if (token) {
      this.setAuthHeader(token);
    }
  }

  /**
   * Login user with email and password
   * @param credentials Login credentials (email, password)
   * @returns Promise with auth response
   */
  public async login(credentials: LoginCredentials): Promise<AuthResponse> {
    try {
      const response = await apiClient.post<AuthResponse>('/auth/login', {
        email: credentials.email,
        password: credentials.password,
      });

      if (response.data.success && response.data.data) {
        this.storeTokens(
          response.data.data.accessToken,
          response.data.data.refreshToken
        );
      }

      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Register new user
   * @param credentials Registration credentials
   * @returns Promise with auth response
   */
  public async register(credentials: RegisterCredentials): Promise<AuthResponse> {
    try {
      const response = await apiClient.post<AuthResponse>('/auth/register', {
        email: credentials.email,
        password: credentials.password,
        confirmPassword: credentials.confirmPassword,
        firstName: credentials.firstName,
        lastName: credentials.lastName,
      });

      if (response.data.success && response.data.data) {
        this.storeTokens(
          response.data.data.accessToken,
          response.data.data.refreshToken
        );
      }

      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get current user information
   * @returns Promise with user data
   */
  public async me(): Promise<MeResponse> {
    try {
      const response = await apiClient.get<MeResponse>('/auth/me');
      return response.data;
    } catch (error) {
      // If unauthorized, clear tokens
      if (axios.isAxiosError(error) && error.response?.status === 401) {
        this.clearTokens();
      }
      throw this.handleError(error);
    }
  }

  /**
   * Refresh access token using refresh token
   * @returns Promise with new tokens
   */
  public async refreshToken(): Promise<RefreshTokenResponse> {
    try {
      const refreshToken = this.getRefreshToken();

      if (!refreshToken) {
        throw new Error('No refresh token available');
      }

      const response = await apiClient.post<RefreshTokenResponse>(
        '/auth/refresh-token',
        {
          refreshToken,
        }
      );

      if (response.data.success) {
        this.storeTokens(
          response.data.data.accessToken,
          response.data.data.refreshToken
        );
      }

      return response.data;
    } catch (error) {
      this.clearTokens();
      throw this.handleError(error);
    }
  }

  /**
   * Logout user
   * @returns Promise with logout response
   */
  public async logout(): Promise<{ success: boolean; message: string }> {
    try {
      const response = await apiClient.post('/auth/logout', {});
      this.clearTokens();
      return response.data;
    } catch (error) {
      // Clear tokens even if logout API fails
      this.clearTokens();
      throw this.handleError(error);
    }
  }

  /**
   * Check if user is authenticated
   * @returns Boolean indicating if user has valid access token
   */
  public isAuthenticated(): boolean {
    return !!this.getAccessToken();
  }

  /**
   * Handle API errors
   */
  private handleError(error: unknown): Error {
    if (axios.isAxiosError(error)) {
      const message =
        error.response?.data?.message ||
        error.message ||
        'An error occurred';
      return new Error(message);
    }
    return error instanceof Error ? error : new Error('An unknown error occurred');
  }
}

// Create and export singleton instance
export const authService = new AuthService();

// Initialize on import
authService.initialize();

export default authService;
