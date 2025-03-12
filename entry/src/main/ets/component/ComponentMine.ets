import { getUserInfo, UserData, UserModel } from '../utils/network/NetWorkUserInfo';
import { promptAction, router } from '@kit.ArkUI';
import { AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { Count, localCountStorage } from '../pages/PageContent';

const TAG: string = 'ComponentMine'

enum Gender {
  MALE = 0,
  FEMALE = 1
}

@Extend(Button) function customButtonStyle() {
  .width('100%').backgroundColor('rgba(255,255,255,0.3)').fontColor($r('app.color.text_primary'))
}

interface UserInfoLocal {
  avatar: string
  desc: string
  email: string
  gender: string
  nickname: string
}

let userdata: UserInfoLocal = {
  avatar: '',
  desc: '',
  email: '',
  gender: '',
  nickname: '',
}

export const localStorage = new LocalStorage(userdata)

@Preview
@Component
export default struct ComponentMine {
  @LocalStorageLink('userInfoLocal')
  userInfoLocal: Partial<UserInfoLocal> = {}
  @LocalStorageProp('count')
  innerCount: Count = {
    count: 0
  }
  @State contentList: string[] = ['用户昵称', '用户性别', '用户简介']

  aboutToAppear(): void {
    getUserInfo()
      .then((res: AxiosResponse<UserModel>) => {
        promptAction.showToast({
              message: res.data.message,
              duration: 1000,
              alignment: Alignment.Bottom
            })
            this.userInfoLocal.desc = res.data.data.desc
            this.userInfoLocal.email = res.data.data.email
            this.userInfoLocal.gender = res.data.data.gender == 0 ? '男' : '女'
            this.userInfoLocal.nickname = res.data.data.nickname
            this.userInfoLocal.avatar = res.data.data.avatar
        localStorage.setOrCreate('userInfoLocal', this.userInfoLocal)
      })
      .catch((e: BusinessError) => {
        promptAction.showToast({
            message: e.message,
            duration: 1000,
            alignment: Alignment.Bottom
        })
      })

    const count = localCountStorage.get<Count>('count')
    if(count) {
      this.innerCount = count
    }
  }

  @Styles bgStyle() {
    .backgroundColor('rgba(255,255,255,0.3)').borderRadius(20)
  }

  @Builder header() {
    Stack() {
      Column() {
        Text(this.userInfoLocal.nickname).fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary'))
        Text() {
          Span(this.userInfoLocal.email).fontColor($r('app.color.primary'))
          ImageSpan($r('app.media.ic_eye_close')).width(16)
        }
        Text(`还有${this.innerCount? this.innerCount.count:0}条待办事项`).fontSize(14).margin({top: 10})
      }.width('100%').height(160).bgStyle().justifyContent(FlexAlign.Center)
      Image(this.userInfoLocal.avatar).width(48).position({
        top: -30,
        left: '45%'
      })
    }
    .width('100%')
  }

  getContent(index: number) {
    switch (index) {
      case 0:
        return this.userInfoLocal.nickname
      case 1:
        return this.userInfoLocal.gender
      case 2:
        return this.userInfoLocal.desc
      default:
        return ''
    }
  }

  @Builder inputContent() {
    List() {
      ForEach(this.contentList, (item: string, index) => {
        ListItem() {
          Row() {
            Text(item).fontColor($r('app.color.text_color_02')).fontSize(14)
            Text(this.getContent(index)).fontColor($r('app.color.text_color_02')).fontSize(14)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(20)
        }
      })
    }.width('100%').bgStyle().divider({strokeWidth: 2, color: $r('app.color.primary')})
  }

  build() {
    Column({space: 20}) {
      this.header()
      this.inputContent()

      Button($r('app.string.edit_user_info')).customButtonStyle().onClick(() => {
          router.pushUrl({
            url: 'pages/PageUpdateUserInfo'
          })
        })
      Button($r('app.string.quit_login')).customButtonStyle().onClick(() => {
        router.replaceUrl({
          url: 'pages/PageLoginAndRegister'
        })
      })
    }
    .width('100%')
    .height('100%')
    .padding({
      top: 40,
      left: 10,
      right: 10
    })
    .backgroundColor('rgba(0,0,0,0.3)')
    .backgroundImage(this.userInfoLocal.avatar)
    .backgroundImageSize(ImageSize.FILL)
  }
}