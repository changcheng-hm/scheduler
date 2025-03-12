import { router } from '@kit.ArkUI';

@Extend(Text) function contentTextStyle() {
  .fontColor(Color.White)
  .fontWeight(FontWeight.Bold)
  .fontSize(30)
}

@Entry
@Component
struct Index {
  @State count: number = 5
  intervalId: number = 0

  @State splash_content1_x: number = -300
  @State splash_content2_x: number = 300

  goToNextPage() {
    clearInterval(this.intervalId)
    router.replaceUrl({
      url: 'pages/PageLoginAndRegister'
    })
  }

  onPageShow(): void {
    this.splash_content1_x = 0
    this.splash_content2_x = 0
    this.intervalId = setInterval(() => {
      if(this.count > 0) {
        this.count--
      } else {
        this.goToNextPage()
      }
    }, 1000)
  }

  @Builder header() {
      Text(`剩余${this.count}秒`)
        .fontSize(14)
        .fontColor(Color.White)
        .padding(12).backgroundColor('rgba(0,0,0,0.4)')
        .position({
          top: 0,
          right: 0
        })
        .borderRadius(20)
        .onClick(() => {
          this.goToNextPage()
        })
  }

  @Builder content() {
    Column({ space: 5 }) {
      Text($r('app.string.splash_content1')).contentTextStyle().translate({x: this.splash_content1_x}).animation({})
      Text($r('app.string.splash_content2')).contentTextStyle().translate({x: this.splash_content2_x}).animation({})
    }
  }

  @Builder bottom() {
    Text($r('app.string.splash_tips'))
      .fontSize(16)
      .fontColor(Color.White)
      .position({
        bottom: 0,
        left: '28%'
      })
  }

  build() {
    Stack() {
      this.header()
      this.content()
      this.bottom()
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor($r('app.color.primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}