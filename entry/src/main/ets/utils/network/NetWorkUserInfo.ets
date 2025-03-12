import { AxiosResponse } from '@ohos/axios';
import { req } from './Network';

import { creator } from './NetWorkLoginAndRegister';

export interface UserModel {
  /**
   * 响应数据
   */
  data: UserData;
  /**
   * 响应消息
   */
  message: string;
}

export interface UserData {
  /**
   * 用户头像地址
   */
  avatar: string;
  /**
   * 用户简介
   */
  desc: string;
  /**
   * 用户邮箱
   */
  email: string;
  /**
   * 用户性别, 0男1女
   */
  gender: number;
  /**
   * 用户昵称
   */
  nickname: string;
}

interface ModifyUserData {
  /**
   * 外号, 外号-修改自己的用户数据
   */
  creator: string;
  /**
   * 用户简介
   */
  desc: string;
  /**
   * 用户邮箱
   */
  email: string;
  /**
   * 用户性别, 0男  1女
   */
  gender: number;
  /**
   * 用户昵称
   */
  nickname: string;
}

interface ModifyAvatar {
  avatar: string
  creator: string
}

export interface ModifyAvatarRes {
  message: string
  data: ModifyAvatar
}

enum Gender {
  MALE = 0,
  FEMALE = 1
}

export async function getUserInfo() {
  return await req.get('/api/settings', {
      params: {
        creator: creator
      }
  })
}

export async function modifyUserInfo(desc: string, email: string, gender: number, nickname: string) {
    return await req.put<UserModel, AxiosResponse<UserModel>, ModifyUserData>('/api/settings', {
      creator: creator,
      desc: desc,
      email: email,
      gender: gender,
      nickname: nickname,
    })
}

export async function modifyUserAvatar(picPath: string) {
    return await req.put<ModifyAvatarRes, AxiosResponse<ModifyAvatarRes>, ModifyAvatar>('/api/avatar', {
      creator: creator,
      avatar: picPath
    }, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
}