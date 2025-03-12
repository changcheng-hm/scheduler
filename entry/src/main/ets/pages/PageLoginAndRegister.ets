import { register, login } from '../utils/network/NetWorkLoginAndRegister'
import { router } from '@kit.ArkUI';

@Extend(TextInput) function textInputStyle() {
  .margin({top: 20})
  .placeholderColor($r('app.color.text_light_primary'))
  .fontColor($r('app.color.text_light_primary'))
  .border({
    width: {
      bottom: 4
    },
    color: $r('app.color.text_light_primary'),
    radius: 0
  })
  .passwordIcon({
    onIconSrc: $r('app.media.ic_eye_open'),
    offIconSrc: $r('app.media.ic_eye_close')
  })
}

const unameReg = /^[a-zA-Z0-9_-]{8,16}$/
const pwdReg = /^\S*(?=\S{6,})(?=\S*\d)(?=\S*[A-Z])(?=\S*[a-z])(?=\S*[!@#$%^&*? ])\S*$/

interface ILoginInfo {
  username: string
  password: string
}

@Entry
@Component
struct PageLoginAndRegister {
  @State username: string = ''
  @State password: string = ''
  @State password_again: string = ''
  @State sheetIsShow: boolean = false

  @Builder registerBuilder() {
    Column() {
      TextInput({placeholder: $r('app.string.hint_username'), text: $$this.username}).type(InputType.USER_NAME).textInputStyle()
      TextInput({placeholder: $r('app.string.hint_password'), text: $$this.password}).type(InputType.Password).textInputStyle()
      TextInput({placeholder: $r('app.string.input_password_again'), text: $$this.password_again}).type(InputType.Password).textInputStyle()
      Button($r('app.string.register_button')).width('100%').backgroundColor($r('app.color.primary')).margin({top: $r('app.integer.register_margin')})
        .onClick(() => {
          //1.校验用户名、密码合法，校验两次密码相同
          if(!unameReg.test(this.username) || !pwdReg.test(this.password) || this.password != this.password_again) {
            AlertDialog.show({
              message: $r('app.string.account_password_empty')
            })
            return
          }
          //2.注册请求
          register(this.username, this.password)
          //3.消除sheet
          this.sheetIsShow = false
        })
    }.height('100%').backgroundImage($r("app.media.beauty")).backgroundImageSize(ImageSize.Cover).padding($r('app.integer.register_padding'))
  }

  @Builder header() {
    Stack() {
      Image($r('app.media.todoBg')).width(60).borderRadius(30)
      Image($r('app.media.todoLog')).width(60).borderRadius(30)
    }
    Text() {
      Span($r('app.string.splash_content1'))
      Span('  ')
      Span($r('app.string.splash_content2'))
    }.fontColor($r('app.color.text_light_primary')).margin({top: 10}).fontSize(14)
    Text($r('app.string.account')).fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_light_primary')).margin({top: 30})
    Text($r('app.string.account_description')).fontSize(14).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_light_primary')).margin({top: 10})
  }

  @Builder inputArea() {
    // 输入框区域
    TextInput({placeholder: $r('app.string.hint_username'), text: $$this.username}).type(InputType.USER_NAME).textInputStyle()
    TextInput({placeholder: $r('app.string.hint_password'), text: $$this.password}).type(InputType.Password).textInputStyle()
  }

  @Builder buttonArea() {
    // 按键区域
    Button($r('app.string.login_button')).width('100%').fontColor($r('app.color.primary')).backgroundColor(Color.White).margin({top: 40})
      .onClick(() => {
        //1.校验用户名、密码合法
        if(!unameReg.test(this.username) || !pwdReg.test(this.password)) {
          AlertDialog.show({
            message: $r('app.string.account_password_empty')
          })
          return
        }
        //2.登录请求
        login(this.username, this.password)
          .then((loginSuccess) => {
            if(loginSuccess) {
              router.replaceUrl({
                url: 'pages/PageContent'
              })
            }
          })
        //3.存储用户数据
        AppStorage.setOrCreate('loginInfo', {
          username: this.username,
          password: this.password,
        })
      })
    Button($r('app.string.register_button')).width('100%').backgroundColor($r('app.color.primary')).margin({top: 15})
      .bindSheet($$this.sheetIsShow, this.registerBuilder(), {
        height: 580
      })
      .onClick(() => {
        this.sheetIsShow = true
      })
  }

  @Builder bottomArea() {
    Row() {
      Text($r('app.string.privacy_statement')).fontColor(Color.White)
      Text($r('app.string.verification_code_login')).fontColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  aboutToAppear(): void {
    PersistentStorage.persistProp('loginInfo',{
      username: '',
      password: '',
    })
    const persistData = AppStorage.get<ILoginInfo>('loginInfo')
    this.username = persistData? persistData.username : ''
    this.password = persistData? persistData.password : ''
  }

  build() {
    Stack() {
      Column() {
        this.header()
        this.inputArea()
        this.buttonArea()
      }
      .width('100%')
      .height('100%')
      this.bottomArea()
    }
    .alignContent(Alignment.Bottom)
    .backgroundImage($r("app.media.beauty"))
    .backgroundImageSize(ImageSize.Cover)
    .padding(20)
    .height('100%')
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}