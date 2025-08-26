# Onclo

Onclo (ON-cloh) is a time-tracking mobile app designed to help you put each of your precious minutes **on** the **clo**ck. Use it to gain insight into how you spend your time and stay on track with your goals.

**DISCLAIMER:** Onclo is in very early development with no stability or backwards compatibility guarantees. As such, it is currently in closed beta and not publicly available.

## Screenshots

<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/92933d03-f964-4152-befa-bf7721edaa3b" />

*Viewing all sessions.*

<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/4ab04ac7-cedd-4d97-815c-3b88580b5616" />

*Viewing details for a single session.*

<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/98e93a99-864b-4a6b-b8e4-d862165d4a59" />

*Adding a session. Suggestions allow you to select common activities with one tap.*

<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/ad14f980-1f14-471c-b2be-208534bd92cb" />

*Editing the end time of a session.*

<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/daa56b18-4100-498b-8361-b3b7ed77f148" />
<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/b9df15f7-5f8e-4a2a-a50a-92e41e27aa0e" />

*Swiping left on a session to edit the freeform note.*

<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/d5a418b8-abdd-4d91-be09-2067c5f156e7" />
<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/36ae5957-6cae-44cd-b95e-641757e7c12b" />

*Long-pressing on a session to edit the activity.*

<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/bb3a435f-3381-4a47-b780-ad000f2748b2" />
<img width="207" height="448" alt="image" src="https://github.com/user-attachments/assets/bf76d287-339f-4e06-9577-882127659d71" />

*Swiping right on a session to delete it.*

## Usage

Onclo records *sessions* of *activities*. For example, brushing your teeth is an *activity*, whereas the particular instance when you brushed your teeth for five minutes on January 1st, 1970 at 6:10 am (let's say) is a *session*. That is to say, sessions are instantiations of activities.

Onclo helps you partition your life's minutes into sessions, so that you can answer questions about your time usage. What the heck did you even do last Friday? When was the last time you rewatched *The Lord of the Rings*? How long, on average, did you spend getting ready each morning in the past month? How many hours have you put towards that side project in the past year? How frequently (that is, in how many distinct sessions) did you work on that side project?

There are many more questions one can answer with this data. If you're like me, you may not ask these questions all that frequently, letting many days of data go unused. But if you ever want an answer, there is no substitute for having *all* the data. Even for infrequent queries, tracking your time can become worth it so long as the cost of recording the data can be brought low enough. That is the problem that Onclo tries to solve. It aims to make recording sessions as fast and as painless as possible, minimizing the costs imposed by time spent tracking and by interrupting your life to track.

**Under construction: more details to come.**

## Development

This project uses [build_runner](https://pub.dev/packages/build_runner). Run `dart run build_runner build` to generate the database models.
