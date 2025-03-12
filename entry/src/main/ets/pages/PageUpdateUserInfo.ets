import { promptAction, router } from '@kit.ArkUI';
import { AxiosResponse } from '@ohos/axios';
import { ModifyAvatarRes, modifyUserAvatar, modifyUserInfo, UserModel } from '../utils/network/NetWorkUserInfo';
import { BusinessError } from '@kit.BasicServicesKit';
import { localStorage } from '../component/ComponentMine';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';

interface UserInfoLocal {
  avatar: string
  desc: string
  email: string
  gender: string
  nickname: string
}

@Entry(localStorage)
@Component
struct UpdateUserInfo {
  @LocalStorageLink('userInfoLocal')
  userInfoLocal: UserInfoLocal = {
    avatar: '',
    desc: '',
    email: '',
    gender: '',
    nickname: '',
  }
  genderN: number = 0

  selectPic() {
    const photoSelectOptions = new picker.PhotoSelectOptions()
    photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
    photoSelectOptions.maxSelectNumber = 1

    const photoViewPicker = new picker.PhotoViewPicker()
    photoViewPicker.select(photoSelectOptions).then(res => {
      const uri = res.photoUris[0]
      const ctx = getContext(this)
      const fileType = 'jpg'
      const fileName = Date.now() + '.' + fileType
      const copyFilePath = ctx.cacheDir + '/' + fileName
      const file = fs.openSync(uri, fs.OpenMode.READ_ONLY)
      fs.copyFileSync(file.fd, copyFilePath)
      modifyUserAvatar(copyFilePath)
        .then((res: AxiosResponse<ModifyAvatarRes>) => {
            promptAction.showToast({
              message: res.data.message,
              duration: 1000,
              alignment: Alignment.Bottom
            })
            this.userInfoLocal.avatar = res.data.data.avatar
        })
        .catch ((e: BusinessError) => {
          promptAction.showToast({
            message: e.message,
            duration: 1000,
            alignment: Alignment.Bottom
          })
      })
    })
  }

  @Builder header() {
    Image($r('app.media.arrow_left')).width(20).alignSelf(ItemAlign.Start).onClick(() => {
      router.back()
    })
    Image(this.userInfoLocal.avatar).width(48).margin({top: 20, bottom: 20}).onClick(() => {
      this.selectPic()
    })
  }

  @Builder content() {
    Column({space: 20}) {
      Row({space: 5}) {
        Text() {
          Span($r('app.string.nickname'))
          Span(':')
        }
        TextInput({placeholder: $r('app.string.hint_nickname'), text: $$this.userInfoLocal.nickname}).layoutWeight(1).type(InputType.USER_NAME)
          .border({
            width: {
              bottom: 1
            },
            radius: 0
          }).backgroundColor(Color.White)
      }.width('100%')
      Row({space: 5}) {
        Text() {
          Span($r('app.string.user_gender'))
          Span(':')
        }
        Select([{ value: '男'}, { value: '女'}])
          .value(this.userInfoLocal.gender)
          .selected(this.genderN)
          .font({ size: 16, weight: 500 })
          .fontColor($r('app.color.text_primary'))
          .selectedOptionFont({ size: 16, weight: 400 })
          .optionFont({ size: 16, weight: 400 })
          .menuAlign(MenuAlignType.START, { dx: 0, dy: 0 })
          .optionWidth(150)
          .optionHeight(300)
          .onSelect((index: number, text?: string | undefined) => {
            this.genderN = index
            console.info('Select:' + index)
            if (text) {
              this.userInfoLocal.gender = text;
            }
          }).layoutWeight(1)
      }.width('100%')
      Column({space: 10}) {
        Text() {
          Span($r('app.string.user_desc'))
          Span(':')
        }
        TextArea({
          text: $$this.userInfoLocal.desc,
          placeholder: '用户简介...'
        }).width('100%').height(100).maxLines(2).maxLength(50).placeholderFont({
          size: 16
        }).borderRadius(10)
      }.width('100%').alignItems(HorizontalAlign.Start)
      // 修改按钮
      Text($r('app.string.agree_modify')).width('100%').backgroundColor($r('app.color.primary')).borderRadius(10).textAlign(TextAlign.Center).padding(10).fontColor($r('app.color.text_light_primary'))
        .onClick(() => {
          modifyUserInfo(this.userInfoLocal.desc, this.userInfoLocal.email, this.genderN, this.userInfoLocal.nickname)
            .then((res: AxiosResponse<UserModel>) => {
              promptAction.showToast({
                message: res.data.message,
                duration: 1000,
                alignment: Alignment.Bottom
              })
              router.back()
            })
            .catch((e: BusinessError) => {
              promptAction.showToast({
                message: e.message,
                duration: 1000,
                alignment: Alignment.Bottom
              })
            })
        })
    }.width('100%').height('100%').padding(10)
  }

  // aboutToAppear(): void {
  //   getUserInfo()
  //     .then((res: AxiosResponse<UserModel>) => {
  //       promptAction.showToast({
  //         message: res.data.message,
  //         duration: 1000,
  //         alignment: Alignment.Bottom
  //       })
  //       this.userdata.desc = res.data.data.desc
  //       this.userdata.gender = res.data.data.gender == 0 ? '男' : '女'
  //       this.userdata.nickname = res.data.data.nickname
  //       this.userdata.email = res.data.data.email
  //       this.userdata.avatar = res.data.data.avatar
  //     })
  //     .catch((e: BusinessError) => {
  //       promptAction.showToast({
  //         message: e.message,
  //         duration: 1000,
  //         alignment: Alignment.Bottom
  //       })
  //     })
  // }

  build() {
    Column() {
      this.header()
      this.content()
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}