import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

/**
 * ============================================================================
 * TYPE DEFINITIONS
 * ============================================================================
 */

// Auth Types
export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  role: 'admin' | 'user' | 'guest';
  permissions: string[];
  createdAt: Date;
}

export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  token: string | null;
  refreshToken: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  register: (email: string, password: string, name: string) => Promise<void>;
  refreshAccessToken: () => Promise<void>;
  updateUser: (user: Partial<User>) => void;
  clearError: () => void;
}

// Order Types
export interface OrderItem {
  id: string;
  productId: string;
  productName: string;
  quantity: number;
  price: number;
  total: number;
}

export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  status: 'pending' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  totalAmount: number;
  shippingAddress: string;
  shippingCost: number;
  tax: number;
  discount: number;
  paymentMethod: 'credit_card' | 'debit_card' | 'paypal' | 'bank_transfer';
  paymentStatus: 'pending' | 'completed' | 'failed' | 'refunded';
  createdAt: Date;
  updatedAt: Date;
  estimatedDelivery?: Date;
  trackingNumber?: string;
}

export interface OrderFilters {
  status?: Order['status'];
  paymentStatus?: Order['paymentStatus'];
  dateRange?: { start: Date; end: Date };
  minAmount?: number;
  maxAmount?: number;
}

export interface OrdersState {
  orders: Order[];
  selectedOrder: Order | null;
  isLoading: boolean;
  error: string | null;
  filters: OrderFilters;
  pagination: { page: number; limit: number; total: number };
  fetchOrders: (filters?: OrderFilters) => Promise<void>;
  fetchOrderById: (id: string) => Promise<void>;
  createOrder: (order: Omit<Order, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>;
  updateOrder: (id: string, updates: Partial<Order>) => Promise<void>;
  cancelOrder: (id: string) => Promise<void>;
  deleteOrder: (id: string) => Promise<void>;
  setSelectedOrder: (order: Order | null) => void;
  setFilters: (filters: OrderFilters) => void;
  setPage: (page: number) => void;
  clearError: () => void;
}

// Notification Types
export type NotificationType = 'success' | 'error' | 'warning' | 'info';

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  duration?: number;
  action?: { label: string; callback: () => void };
  timestamp: Date;
}

export interface NotificationsState {
  notifications: Notification[];
  addNotification: (notification: Omit<Notification, 'id' | 'timestamp'>) => string;
  removeNotification: (id: string) => void;
  clearNotifications: () => void;
  updateNotification: (id: string, updates: Partial<Notification>) => void;
}

// Metrics Types
export interface MetricDataPoint {
  timestamp: Date;
  value: number;
  label?: string;
}

export interface MetricsSummary {
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  conversionRate: number;
  customerCount: number;
  repeatCustomerRate: number;
  topProducts: Array<{ id: string; name: string; sales: number; revenue: number }>;
  recentActivity: Array<{ id: string; type: string; description: string; timestamp: Date }>;
}

export interface MetricsState {
  summary: MetricsSummary | null;
  timeSeries: { [key: string]: MetricDataPoint[] };
  isLoading: boolean;
  error: string | null;
  dateRange: { start: Date; end: Date };
  fetchMetrics: (dateRange?: { start: Date; end: Date }) => Promise<void>;
  fetchTimeSeries: (metric: string, dateRange?: { start: Date; end: Date }) => Promise<void>;
  setDateRange: (start: Date, end: Date) => void;
  clearError: () => void;
}

// Theme Types
export type ThemeMode = 'light' | 'dark' | 'auto';

export interface ThemeColors {
  primary: string;
  secondary: string;
  success: string;
  warning: string;
  error: string;
  info: string;
  background: string;
  surface: string;
  text: string;
  textSecondary: string;
  border: string;
}

export interface ThemeState {
  mode: ThemeMode;
  colors: ThemeColors;
  isDark: boolean;
  setThemeMode: (mode: ThemeMode) => void;
  toggleTheme: () => void;
  updateColors: (colors: Partial<ThemeColors>) => void;
  resetTheme: () => void;
}

/**
 * ============================================================================
 * STORE CREATORS
 * ============================================================================
 */

/**
 * Auth Store - Manages user authentication and authorization
 */
export const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      (set) => ({
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
        token: null,
        refreshToken: null,

        login: async (email: string, password: string) => {
          set({ isLoading: true, error: null });
          try {
            // TODO: Replace with actual API call
            // const response = await api.post('/auth/login', { email, password });
            // set({ user: response.user, token: response.token, isAuthenticated: true });
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Login failed',
              isLoading: false,
            });
            throw error;
          }
        },

        logout: () => {
          set({
            user: null,
            isAuthenticated: false,
            token: null,
            refreshToken: null,
            error: null,
          });
        },

        register: async (email: string, password: string, name: string) => {
          set({ isLoading: true, error: null });
          try {
            // TODO: Replace with actual API call
            // const response = await api.post('/auth/register', { email, password, name });
            // set({ user: response.user, token: response.token, isAuthenticated: true });
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Registration failed',
              isLoading: false,
            });
            throw error;
          }
        },

        refreshAccessToken: async () => {
          set({ isLoading: true });
          try {
            // TODO: Replace with actual API call
            // const response = await api.post('/auth/refresh', { refreshToken: this.refreshToken });
            // set({ token: response.token });
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Token refresh failed',
              isLoading: false,
            });
            throw error;
          }
        },

        updateUser: (updates: Partial<User>) => {
          set((state) => ({
            user: state.user ? { ...state.user, ...updates } : null,
          }));
        },

        clearError: () => set({ error: null }),
      }),
      {
        name: 'auth-storage',
        partialize: (state) => ({
          user: state.user,
          token: state.token,
          refreshToken: state.refreshToken,
          isAuthenticated: state.isAuthenticated,
        }),
      }
    )
  )
);

/**
 * Orders Store - Manages orders and order-related operations
 */
export const useOrdersStore = create<OrdersState>()(
  devtools(
    persist(
      (set, get) => ({
        orders: [],
        selectedOrder: null,
        isLoading: false,
        error: null,
        filters: {},
        pagination: { page: 1, limit: 10, total: 0 },

        fetchOrders: async (filters?: OrderFilters) => {
          set({ isLoading: true, error: null });
          try {
            // TODO: Replace with actual API call
            // const response = await api.get('/orders', { params: { ...filters, ...pagination } });
            // set({ orders: response.orders, pagination: response.pagination });
            if (filters) set({ filters });
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Failed to fetch orders',
              isLoading: false,
            });
            throw error;
          }
        },

        fetchOrderById: async (id: string) => {
          set({ isLoading: true, error: null });
          try {
            // TODO: Replace with actual API call
            // const response = await api.get(`/orders/${id}`);
            // set({ selectedOrder: response.order });
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Failed to fetch order',
              isLoading: false,
            });
            throw error;
          }
        },

        createOrder: async (orderData: Omit<Order, 'id' | 'createdAt' | 'updatedAt'>) => {
          set({ isLoading: true, error: null });
          try {
            // TODO: Replace with actual API call
            // const response = await api.post('/orders', orderData);
            // set((state) => ({ orders: [response.order, ...state.orders] }));
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Failed to create order',
              isLoading: false,
            });
            throw error;
          }
        },

        updateOrder: async (id: string, updates: Partial<Order>) => {
          set({ isLoading: true, error: null });
          try {
            // TODO: Replace with actual API call
            // const response = await api.patch(`/orders/${id}`, updates);
            set((state) => ({
              orders: state.orders.map((order) => (order.id === id ? { ...order, ...updates } : order)),
              selectedOrder: state.selectedOrder?.id === id ? { ...state.selectedOrder, ...updates } : state.selectedOrder,
            }));
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Failed to update order',
              isLoading: false,
            });
            throw error;
          }
        },

        cancelOrder: async (id: string) => {
          set({ isLoading: true, error: null });
          try {
            // TODO: Replace with actual API call
            // await api.post(`/orders/${id}/cancel`);
            set((state) => ({
              orders: state.orders.map((order) =>
                order.id === id ? { ...order, status: 'cancelled' as const } : order
              ),
            }));
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Failed to cancel order',
              isLoading: false,
            });
            throw error;
          }
        },

        deleteOrder: async (id: string) => {
          set({ isLoading: true, error: null });
          try {
            // TODO: Replace with actual API call
            // await api.delete(`/orders/${id}`);
            set((state) => ({
              orders: state.orders.filter((order) => order.id !== id),
              selectedOrder: state.selectedOrder?.id === id ? null : state.selectedOrder,
            }));
            set({ isLoading: false });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Failed to delete order',
              isLoading: false,
            });
            throw error;
          }
        },

        setSelectedOrder: (order: Order | null) => set({ selectedOrder: order }),

        setFilters: (filters: OrderFilters) => {
          set({ filters, pagination: { page: 1, limit: 10, total: 0 } });
          get().fetchOrders(filters);
        },

        setPage: (page: number) => {
          set((state) => ({ pagination: { ...state.pagination, page } }));
        },

        clearError: () => set({ error: null }),
      }),
      {
        name: 'orders-storage',
        partialize: (state) => ({
          filters: state.filters,
          pagination: state.pagination,
        }),
      }
    )
  )
);

/**
 * Notifications Store - Manages toast notifications and alerts
 */
export const useNotificationsStore = create<NotificationsState>()(
  devtools((set) => ({
    notifications: [],

    addNotification: (notification: Omit<Notification, 'id' | 'timestamp'>) => {
      const id = `${Date.now()}-${Math.random()}`;
      const newNotification: Notification = {
        ...notification,
        id,
        timestamp: new Date(),
      };

      set((state) => ({ notifications: [newNotification, ...state.notifications] }));

      // Auto-remove notification after duration
      if (notification.duration) {
        setTimeout(() => {
          set((state) => ({
            notifications: state.notifications.filter((n) => n.id !== id),
          }));
        }, notification.duration);
      }

      return id;
    },

    removeNotification: (id: string) => {
      set((state) => ({
        notifications: state.notifications.filter((n) => n.id !== id),
      }));
    },

    clearNotifications: () => set({ notifications: [] }),

    updateNotification: (id: string, updates: Partial<Notification>) => {
      set((state) => ({
        notifications: state.notifications.map((n) => (n.id === id ? { ...n, ...updates } : n)),
      }));
    },
  }))
);

/**
 * Metrics Store - Manages analytics and metrics data
 */
export const useMetricsStore = create<MetricsState>()(
  devtools((set) => {
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    return {
      summary: null,
      timeSeries: {},
      isLoading: false,
      error: null,
      dateRange: { start: thirtyDaysAgo, end: now },

      fetchMetrics: async (dateRange?: { start: Date; end: Date }) => {
        set({ isLoading: true, error: null });
        try {
          // TODO: Replace with actual API call
          // const response = await api.get('/metrics', {
          //   params: { startDate: dateRange?.start, endDate: dateRange?.end }
          // });
          // set({ summary: response.summary });
          if (dateRange) set({ dateRange });
          set({ isLoading: false });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Failed to fetch metrics',
            isLoading: false,
          });
          throw error;
        }
      },

      fetchTimeSeries: async (metric: string, dateRange?: { start: Date; end: Date }) => {
        set({ isLoading: true, error: null });
        try {
          // TODO: Replace with actual API call
          // const response = await api.get(`/metrics/timeseries/${metric}`, {
          //   params: { startDate: dateRange?.start, endDate: dateRange?.end }
          // });
          // set((state) => ({ timeSeries: { ...state.timeSeries, [metric]: response.data } }));
          set({ isLoading: false });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : `Failed to fetch ${metric} timeseries`,
            isLoading: false,
          });
          throw error;
        }
      },

      setDateRange: (start: Date, end: Date) => {
        set({ dateRange: { start, end } });
      },

      clearError: () => set({ error: null }),
    };
  })
);

/**
 * Theme Store - Manages application theme and colors
 */
const DEFAULT_LIGHT_COLORS: ThemeColors = {
  primary: '#3B82F6',
  secondary: '#8B5CF6',
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
  info: '#06B6D4',
  background: '#FFFFFF',
  surface: '#F9FAFB',
  text: '#111827',
  textSecondary: '#6B7280',
  border: '#E5E7EB',
};

const DEFAULT_DARK_COLORS: ThemeColors = {
  primary: '#60A5FA',
  secondary: '#A78BFA',
  success: '#34D399',
  warning: '#FBBF24',
  error: '#F87171',
  info: '#22D3EE',
  background: '#111827',
  surface: '#1F2937',
  text: '#F9FAFB',
  textSecondary: '#D1D5DB',
  border: '#374151',
};

export const useThemeStore = create<ThemeState>()(
  persist(
    (set) => {
      const getSystemTheme = (): 'light' | 'dark' => {
        if (typeof window !== 'undefined') {
          return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
        }
        return 'light';
      };

      const isDarkMode = (mode: ThemeMode): boolean => {
        if (mode === 'auto') {
          return getSystemTheme() === 'dark';
        }
        return mode === 'dark';
      };

      const getColorsForMode = (mode: ThemeMode): ThemeColors => {
        const dark = isDarkMode(mode);
        return dark ? DEFAULT_DARK_COLORS : DEFAULT_LIGHT_COLORS;
      };

      const initialMode: ThemeMode = 'auto';
      const initialColors = getColorsForMode(initialMode);
      const initialIsDark = isDarkMode(initialMode);

      return {
        mode: initialMode,
        colors: initialColors,
        isDark: initialIsDark,

        setThemeMode: (mode: ThemeMode) => {
          set({
            mode,
            isDark: isDarkMode(mode),
            colors: getColorsForMode(mode),
          });
        },

        toggleTheme: () => {
          set((state) => {
            const newMode: ThemeMode = state.mode === 'dark' ? 'light' : 'dark';
            return {
              mode: newMode,
              isDark: isDarkMode(newMode),
              colors: getColorsForMode(newMode),
            };
          });
        },

        updateColors: (newColors: Partial<ThemeColors>) => {
          set((state) => ({
            colors: { ...state.colors, ...newColors },
          }));
        },

        resetTheme: () => {
          set({
            mode: 'auto',
            colors: getColorsForMode('auto'),
            isDark: isDarkMode('auto'),
          });
        },
      };
    },
    {
      name: 'theme-storage',
      partialize: (state) => ({ mode: state.mode, colors: state.colors }),
    }
  )
);

/**
 * ============================================================================
 * UTILITY HOOKS (Optional composition hooks)
 * ============================================================================
 */

/**
 * Combines multiple stores for easier access in components
 */
export const useAppStore = () => {
  const auth = useAuthStore();
  const orders = useOrdersStore();
  const notifications = useNotificationsStore();
  const metrics = useMetricsStore();
  const theme = useThemeStore();

  return {
    auth,
    orders,
    notifications,
    metrics,
    theme,
  };
};

/**
 * Hook to show a success notification
 */
export const useSuccessNotification = () => {
  const { addNotification } = useNotificationsStore();
  return (title: string, message: string, duration = 5000) => {
    addNotification({
      type: 'success',
      title,
      message,
      duration,
    });
  };
};

/**
 * Hook to show an error notification
 */
export const useErrorNotification = () => {
  const { addNotification } = useNotificationsStore();
  return (title: string, message: string, duration = 5000) => {
    addNotification({
      type: 'error',
      title,
      message,
      duration,
    });
  };
};

/**
 * Hook to show a warning notification
 */
export const useWarningNotification = () => {
  const { addNotification } = useNotificationsStore();
  return (title: string, message: string, duration = 5000) => {
    addNotification({
      type: 'warning',
      title,
      message,
      duration,
    });
  };
};

/**
 * Hook to show an info notification
 */
export const useInfoNotification = () => {
  const { addNotification } = useNotificationsStore();
  return (title: string, message: string, duration = 5000) => {
    addNotification({
      type: 'info',
      title,
      message,
      duration,
    });
  };
};