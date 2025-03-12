import date from '@open/date'

export function getCurTime(format: string) {
  return date.format(format)
}