import { AxiosResponse } from '@ohos/axios';
import { promptAction } from '@kit.ArkUI';
import { req } from './Network';

interface UserInfoReq {
  username: string
  password: string
}

interface RegisterData {
  id: number
  account: string
}

interface LoginData {
  username: string
}

interface AccountRes {
  code: number
  message: string
  data: LoginData | RegisterData
}

export let creator: string = ''

export async function register(username: string, password: string) {
  try {
    const res: AxiosResponse<AccountRes> = await req.post<AccountRes, AxiosResponse<AccountRes>, UserInfoReq>('/api/register', {
      username: username,
      password: password
    })
    promptAction.showToast({
      message: res.data.message,
      duration: 1000,
      alignment: Alignment.Bottom
    })
  } catch (e) {
    promptAction.showToast({
      message: e,
      duration: 1000,
      alignment: Alignment.Bottom
    })
  }
}

export async function login(username: string, password: string): Promise<boolean> {
  try {
    const res: AxiosResponse<AccountRes> = await req.post<AccountRes, AxiosResponse<AccountRes>, UserInfoReq>('/api/login', {
      username: username,
      password: password
    })
    promptAction.showToast({
      message: `${res.data.message}，用户名为：${(res.data.data as LoginData).username}`,
      duration: 1000,
      alignment: Alignment.Bottom
    })
    creator = (res.data.data as LoginData).username
    return true
  } catch (e) {
    promptAction.showToast({
      message: e,
      duration: 1000,
      alignment: Alignment.Bottom
    })
    return false
  }
}