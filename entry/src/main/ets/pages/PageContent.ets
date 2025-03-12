import { promptAction } from '@kit.ArkUI';
import ComponentMine from '../component/ComponentMine'
import ComponentKnown from '../component/ComponentNews'
import ComponentTodo from '../component/ComponentTodo'

const TAG: string = 'PageContent'

export interface Count {
  count: number
}

let customCount: Count = {
  count: 0
}

export const localCountStorage = new LocalStorage(customCount)

@Entry(localCountStorage)
@Component
struct PageContent {
  @State message: string = 'Hello World';

  @State tabTitles: string[] = ['去做', '知道', '我的']
  @State tabImages: ResourceStr[] = [$r('app.media.todo'), $r('app.media.known'), $r('app.media.mine')]
  @Builder tabBarBuilder(index: number) {
    Column() {
      Image(this.tabImages[index]).width(24).fillColor($r('app.color.primary'))
      Text(this.tabTitles[index]).fontColor($r('app.color.primary')).fontWeight(FontWeight.Bold).margin({top: 5})
    }
  }

  onPageShow(): void {
    console.log(TAG, 'onPageShow')
  }

  onPageHide(): void {
    console.log(TAG, 'onPageHide')
  }

  build() {
    Tabs() {
      ForEach(this.tabTitles, (item: string, index) => {
        TabContent() {
          if(index == 0) {
            ComponentTodo()
          } else if(index == 1) {
            ComponentKnown()
          } else {
            ComponentMine()
          }
        }.tabBar(this.tabBarBuilder(index))
      })
    }
    .divider({
      strokeWidth: 2,
      color: $r('app.color.primary')
    })
    .scrollable(false)
    .barPosition(BarPosition.End)
    .height('100%')
    .width('100%');
  }

  onBackPress(): boolean | void {
    promptAction.showDialog({
      title: '友情提示',
      message: '你真的要退出应用吗?',
      buttons: [
        {
          text: '确定退出',
          color: $r('app.color.text_light_primary')
        },
        {
          text: '继续使用',
          color: $r('app.color.primary')
        }
      ],
    })
      .then(data => {
        // TODO 添加清空逻辑
        if(data.index == 0) getContext().getApplicationContext().killAllProcesses()
      })
  }
}