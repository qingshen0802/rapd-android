import DS from 'ember-data';

const { attr, hasMany } = DS;
/*#<Event id: 3, user_id: 1, title: "test event 3", content: "", type: "Event", activity_type: "", starts_at: "2016-08-03 16:45:00",
          ends_at: "2016-08-03 16:50:00", due_at: nil,all_day: false, address: "", city: "", state: "", zipcode: "", created_at: "2016-08-03 16:42:14",
          updated_at: "2016-08-03 16:42:14", status: "", latitude: nil, longitude: nil, provider_id: "", ical_id: "", calendar_id: nil,
          listable_id: nil, listable_type: nil, checked_by_id: nil, series_id: nil, alarms: ["30"], timezone: nil, position: nil>
*/
export default DS.Model.extend({
  userId: attr('number'),
  title: attr('string'),
  content: attr('string'),
  type: attr('string'),
  activityType: attr('string'),
  startsAt: attr('date'),
  endsAt: attr('date'),
  dueAt: attr('string'),
  allDay: attr('boolean',{defaultValue: false}),
  address: attr('string',{defaultValue: ""}),
  city: attr('string'),
  state: attr('string'),
  zipcode: attr('string'),
  createdAt: attr('date'),
  updatedAt: attr('date'),
  latitude: attr('string'),
  longitude: attr('string'),
  providerId: attr('number'),
  icalId: attr('number', {defaultValue: ""}),
  calendarId: attr('number'),
  listableId: attr('number'),
  listableType: attr('string'),
  checkedById: attr('number'),
  seriesId: attr('number'),
  timezone: attr('string'),
  position: attr('string'),
  alarms: attr('array',{defaultValue: ["30"]}),
  assigneeId: attr('number'),
  calendarItemParticipants: hasMany('user',{polymorphic: true}),
  lists: hasMany('list')
});
