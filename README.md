# PHOKI <img src="https://user-images.githubusercontent.com/41771874/136984840-735d5ebe-3080-4b47-af7e-78f8c6870b06.png" width = 105 align = left>
[<img src = "https://devimages-cdn.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg">](https://apps.apple.com/us/app/%ED%8F%AC%ED%82%A4/id1562617132#?platform=iphone)    

> iOS 개인 프로젝트 : 포토 캘린더
## What is PHOKI
매일매일 기록하고 싶은 사진을 캘린더에서 모아볼 수 있는 어플   
아카이빙, 성취 인증, 목표 달성 체크 용도로 사용할 수 있습니다 🌏

## Screen shots
<div>
<img src = "https://user-images.githubusercontent.com/41771874/131452440-9d270284-ab2d-4425-b687-6779031f4ecf.png" width = 22% >
<img src = "https://user-images.githubusercontent.com/41771874/131452453-edd9b202-b3e5-40bb-973c-6e26a2ea9372.png" width = 22% >
<img src = "https://user-images.githubusercontent.com/41771874/131452459-05e0ccbb-3c62-4065-a8a7-e63bbafbdf5b.png" width = 22% >
<img src = "https://user-images.githubusercontent.com/41771874/131452465-23e7a889-c50f-45bb-95f2-761b42a39ace.png" width = 22% >
</div>

## Project
- 프로젝트 기간: 2021.2.10 ~ 2021.04.14
- 앱스토어 출시: 2021.04.14
- 개인 프로젝트

## Develop Environment
![SWIFT](https://img.shields.io/static/v1?style=for-the-badge&logo=swift&message=SWIFT&label=&color=FA7343&labelColor=000000)

iOS Deployment Target : iOS 14.4

## Library
- [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView)

## Features
| 기능 | 구현 |   
| - | - |   
| 포토 캘린더 뷰 | ✅ |
| 오늘 사진 추가 | ✅ |
| 하루 사진 여러장 추가 | ✅ |
| 사진 추가, 변경, 삭제 | ✅ |
| 사진 순서 변경 | ✅ |
| 사진 메모 | ✅ |
| 여러개 캘린더 | ✅ |
| 캘린더 배경사진, 이름 변경 | ✅ |
| 캘린더 추가, 삭제 | ✅ |
| 아이클라우드 연동 기능 | ✅ |

## Structure
```
.
   ├── Main.storyboard
├─ Cell
   ├── calendarCell.swift
   ├── calendarInfoCell.swift
├─ Model
   ├── CalendarInfoInstance.swift
   ├── MyContent.swift
├─ Cotroller
   ├── ViewController.swift
   ├── DetailViewController.swift
   ├── CalendarListViewController.swift
   ├── SettingViewController.swift
   ├── AdViewController.swift
   ├── SettingViewController.swift
├─ Helper
   ├── CalendarHelper.swift
   ├── ContentHelper.swift
   └── CalendarInfoHelper.swift
```


## Version
### Ver. 1
- 1.0: App Store release (2021.04.14)
- 1.1: iPad version release, ad 수정 (2021.05.10)
- 1.1.1: 광고 연결, 버그 수정 (2021.06.15)
- 1.1.2: collection view shuffle 문제 수정 (2021.09.20)
- 1.1.3: 메모 줄바꿈 기능 수정 (2021.09.21)
### Ver. 2
- 2.0: cloudKit 연동 (2024.12.12)

###### this page will be updated very sooon ;)
