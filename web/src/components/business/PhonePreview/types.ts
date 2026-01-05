export type DeviceType = 'iphone' | 'android'

export interface PhonePreviewProps {
  device?: DeviceType
  showDeviceSwitch?: boolean
  width?: number
  height?: number
}

export interface DeviceConfig {
  name: string
  width: number
  height: number
  borderRadius: number
  notchType: 'dynamic-island' | 'notch' | 'punch-hole' | 'none'
  statusBarHeight: number
  homeIndicatorHeight: number
}

export const DEVICE_CONFIGS: Record<DeviceType, DeviceConfig> = {
  iphone: {
    name: 'iPhone 15 Pro',
    width: 393,
    height: 852,
    borderRadius: 55,
    notchType: 'dynamic-island',
    statusBarHeight: 59,
    homeIndicatorHeight: 34,
  },
  android: {
    name: 'Android',
    width: 393,
    height: 851,
    borderRadius: 40,
    notchType: 'punch-hole',
    statusBarHeight: 40,
    homeIndicatorHeight: 20,
  },
}
