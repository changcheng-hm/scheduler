import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit';

export let dataPreferences: preferences.Preferences | null = null;

export function initPreferences(context: Context) {
  preferences.getPreferences(context, 'todo', (err: BusinessError, val: preferences.Preferences) => {
    if (err) {
      console.error("Failed to get preferences. code =" + err.code + ", message =" + err.message);
      return;
    }
    dataPreferences = val;
    console.info("Succeeded in getting preferences.");
  })
}
