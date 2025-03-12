import { dataPreferences } from '../utils/local_storage/LocalStorage';
import { getCurTime } from '../utils/TimeUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import { Count, localCountStorage } from '../pages/PageContent';
import { promptAction } from '@kit.ArkUI';

interface TodoCurItem {
  time: string;
  todoItems: TodoItem[];
}

interface TodoCur {
  id: number;
  time: string;
  todo: string;
}

interface TodoItem {
  id: number;
  todo: string;
  checked: boolean;
}

const TAG: string = 'ComponentTodo';

@Preview
@Component
export default struct ComponentTodo {
  @State text: string = '';
  // 显示渲染数组
  @State todoItemList: TodoCurItem[] = [];
  innerCount: Count = {
    count: 0
  };
  // 时间数组
  times: string[] = [];
  // 任务数组
  todoCurList: TodoCur[] = [];

  filterByTime(time: string) {
    const temp = this.todoCurList.filter(item => {
      return item.time == time;
    });
    const todoItems = temp.map<TodoItem>(item => {
      return { id: item.id, todo: item.todo, checked: false };
    });
    this.todoItemList.push({ time, todoItems });
  }

  flat() {
    this.todoItemList = [];
    for (let time of this.times) {
      this.filterByTime(time);
    }
    console.log('todoItemList: ' + this.todoItemList.toString());
  }

  @Builder
  deleteItem(id: number, time: string) {
    Text('删除')
      .fontColor(Color.White)
      .width(40)
      .backgroundColor($r('app.color.primary'))
      .padding({ top: 10, bottom: 10 })
      .textAlign(TextAlign.Center)
      .onClick(() => {
        // 删除任务数组对应元素
        this.todoCurList = [...this.todoCurList.filter(item => item.id != id)];
        // 如果flag是false，说明this.todoCurList数组中已没有对应时间的子项，可以删除times时间数组里的值
        let flag: Boolean = false;
        for (let item of this.todoCurList) {
          if (item.time == time) {
            flag = true;
            break;
          }
        }
        if (!flag) {
          this.times = [...this.times.filter(item => item != time)];
        }
        this.flat();
        // 缓存任务数量
        this.innerCount.count = this.todoCurList.length;
        localCountStorage.setOrCreate('count', this.innerCount);

        dataPreferences?.deleteSync(id.toString());
      });
  }

  @Builder
  subItemHeaderBuilder(time: string) {
    Row() {
      Text(time).fontSize(12)
        .margin({ left: 15 });
    }
    .width('100%')
    .height(40)
    .backgroundColor($r('app.color.bg_2'));
  }

  @Builder
  header() {
    Text($r('app.string.EntryAbility_label'))
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.primary'));
  }

  @Builder
  submitArea() {
    Row() {
      TextArea({
        text: $$this.text,
        placeholder: '待做...'
      })
        .width(220)
        .layoutWeight(1)
        .maxLines(2)
        .maxLength(50)
        .placeholderFont({
          size: 16
        })
        .placeholderColor($r('app.color.text_light_primary'))
        .backgroundColor($r('app.color.primary'))
        .borderRadius(10)
        .showCounter(true);

      Button($r('app.string.submit'), { type: ButtonType.Normal })
        .fontSize(16)
        .fontColor($r('app.color.text_light_primary'))
        .backgroundColor(Color.Blue)
        .padding(15)
        .borderRadius(10)
        .onClick(() => {
          if (this.text.trim() == '') {
            promptAction.showToast({
              message: '内容不能为空',
              duration: 1000
            });
            return;
          }
          // 调整数组
          const curTime = getCurTime('Y-m-d H:i');
          if (!this.times.includes(curTime)) {
            this.times.unshift(curTime);
          }
          const id = Date.now();
          this.todoCurList.unshift({ time: curTime, id: id, todo: this.text });
          this.flat();
          // 缓存任务数量
          this.innerCount.count = this.todoCurList.length;
          localCountStorage.setOrCreate('count', this.innerCount);
          // 将id作为key，时间和todo内容拼接字符串传入
          dataPreferences?.put(id.toString(), curTime + ',' + this.text);
          // 清空输入框
          this.text = '';
          dataPreferences?.flush((err: BusinessError) => {
            if (err) {
              console.error('Failed to flush. code =' + err.code + ', message =' + err.message);
              return;
            }
            console.info('Succeeded in flushing.');
          });
        });
    }.width('100%').padding(20);
  }

  @Builder
  ListArea() {
    List({ space: 5 }) {
      ForEach(this.todoItemList, (item: TodoCurItem, index) => {
        ListItemGroup({
          header: this.subItemHeaderBuilder(item.time)
        }) {
          ForEach(item.todoItems, (subItem: TodoItem, subIndex) => {
            ListItem() {
              Row({ space: 10 }) {
                Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE).width(16).onChange((checked) => {
                  let tempArr = [...this.todoItemList]
                  tempArr[index].todoItems[subIndex].checked = checked
                  this.todoItemList = tempArr
                }).select(subItem.checked)
                Text(subItem.todo)
                  .fontColor(subItem.checked ? $r('app.color.text_color_03') : $r('app.color.text_primary'))
                  .decoration({
                    type: subItem.checked ? TextDecorationType.LineThrough : TextDecorationType.None,
                    color: $r('app.color.text_color_03')
                  })
                  .animation({ duration: 500 });
              }.justifyContent(FlexAlign.Start).width('100%').padding(5);
            }.swipeAction({
              end: this.deleteItem(subItem.id, item.time)
            });
          });
        };
      });
    }.width('100%').layoutWeight(1);
  }

  aboutToAppear(): void {
    const obj = dataPreferences?.getAllSync();
    if (obj) {
      const allKeys = Object.keys(obj);
      for (let key of allKeys) {
        const value = dataPreferences?.getSync(key, '');
        const arr = (value as String).split(',');
        if (!this.times.includes(arr[0])) {
          this.times.push(arr[0]);
        }
        this.todoCurList.push({
          id: Number(key),
          time: arr[0],
          todo: arr[1]
        });
        console.log(TAG, this.todoCurList.toString());
      }
      this.todoCurList.sort((a: TodoCur, b: TodoCur) => {
        return b.id - a.id;
      })
      for(let item of this.todoCurList) {
        if(!this.times.includes(item.time)) {
          this.times.push(item.time)
        }
      }
      this.flat();
      // 缓存任务数量
      this.innerCount.count = this.todoCurList.length;
      localCountStorage.setOrCreate('count', this.innerCount);
    }
  }

  build() {
    Column() {
      this.header();
      this.submitArea();
      this.ListArea();
    }
    .width('100%')
    .height('100%')
  }
}