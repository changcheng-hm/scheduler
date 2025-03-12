import { AxiosResponse } from '@ohos/axios';
import { promptAction } from '@kit.ArkUI';
import { req } from '../utils/network/Network';

interface NewsModel {
  /**
   * 响应数据
   */
  data: New[];
  /**
   * 响应消息
   */
  message: string;
}

export interface New {
  /**
   * 新闻评论总数
   */
  cmtcount: number;
  /**
   * 新闻id
   */
  id: number;
  /**
   * 新闻图片地址
   */
  img: string;
  /**
   * 新闻来源
   */
  source: string;
  /**
   * 新闻发布时间
   */
  time: string;
  /**
   * 新闻标题
   */
  title: string;
}

@Preview
@Component
export default struct ComponentKnown {
  @State list: New[] = []
  @State showLoading: boolean = true

  aboutToAppear(): void {
    this.getNews()
  }

  async getNews() {
    try {
      const res: AxiosResponse<NewsModel> = await req.get('/api/news')
      promptAction.showToast({
        message: res.data.message,
        duration: 1000,
        alignment: Alignment.Bottom
      })
      this.list = res.data.data
      this.showLoading = false
    } catch (e) {
      promptAction.showToast({
        message: e,
        duration: 1000,
        alignment: Alignment.Bottom
      })
    }
  }

  build() {
    Column() {
      LoadingProgress().width(40).visibility(this.showLoading ? Visibility.Visible : Visibility.None)
      List({space: 14}) {
        ForEach(this.list, (item: New) => {
          NewsItem({item: item})
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: 20,
        left: 20,
        right: 20
      })
    }
    .width('100%')
    .height('100%')
  }
}

@Extend(Text) function textStyle() {
  .fontSize(12).fontColor($r('app.color.text_color_03'))
}

@Component
struct NewsItem {
  @Prop item: New

  build() {
    Row({space: 10}) {
      Column() {
        Text(this.item.title).fontSize(16).fontWeight(FontWeight.Bold)
        Row() {
          Row({space: 5}) {
            Text(this.item.source).width(50).maxLines(1).textStyle().textOverflow({overflow: TextOverflow.Ellipsis})
            Text('|').textStyle()
            Text(this.item.cmtcount.toString()).textStyle()
          }
          Text(this.item.time).width(70).maxLines(1).textStyle().textOverflow({overflow: TextOverflow.Ellipsis})
        }.justifyContent(FlexAlign.SpaceBetween).width('100%')
      }.layoutWeight(1).height(100).justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Start)
      Image(this.item.img).width(100).height(100).borderRadius(4)
    }.width('100%')
  }
}