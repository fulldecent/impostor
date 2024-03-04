## Road to publishing

- [x] Localize all UI strings
- [x] Change the game strings to have one file and only pull in the first 80 if not paid
- [x] Localize game strings
- [ ] Integrate Fastlane for screenshots and publish to App Store
- [ ] Publish to App Store



---

NO do v2

1. Redraw all images to SVG // NO DO V2

2. Set up auto version increment

   > [01:50:00]: To enable fastlane to handle automatic version incrementing for you, please follow this guide:
   >
   > [01:50:00]: https://developer.apple.com/library/content/qa/qa1827/_index.html
   >
   > [01:50:00]: Afterwards check out the fastlane docs on how to set up automatic build increments
   >
   > [01:50:00]: https://docs.fastlane.tools/getting-started/ios/beta-deployment/#best-practices

---

Set up auto version increment

---

## How to localize game strings

Intern

> I am building a game based on pairs of words. Players will privately see one word or the other and talk with the other players to determine if their word is the same as the others.
>
> Therefore if the word has multiple meanings like "Apple" which means a fruit and also the name of a company, then it is necessary to show this as "apple (fruit)" or "Apple (company)". Notice how the proper noun is in upper case and the normal noun is in lower case.
>
> This game is fun if most people know the words in the game. For example, a reference to the singer Garth Brooks or Dolly Parton is dated, most people will not know them, and it is a poor choice for this game. For players in the United States Taylor Swift and Britney Spears are a better choice because of their popularity across different demographics.
>
> Additionally, the game is fun only if the pairs of words are similar—a description for one of the items may inadvertantly also describe the other item. For example "spring (season)" and "summer" is a good pair because the weather for these seasons are similar, when describing one, people may think you are describing the other. Whereas "apple (fruit)" and "Apple (company)" is a bad pair because the way you would describe an apple ("it can rot", "has a core and seeds") are nothing close to the Apple company that makes iPhones.
>
> The words are saved in a JSON file. Usually each line is a pair. But if more than two words really are similar, like "McDonald's", "Wendy's (restaurant)" and "Burger King" they can all be on the same line. The game engine will randomly pick two items from the line.
>
> Instructions: please review the below game words list which is intended for a English-United States audience then make any necessary changes, add an additional 15 lines at end, and output the complete updated file.
>
> [PASTE LIST]

And then

> Great job!
>
> Instructions: please review the below game words list which is intended for a China-Simplified Chinese audience then make any necessary changes, steal any ideas from the prior list(s), add an additional 15 lines at end, and output the complete updated file.
>
> [PASTE LIST]

Or

> Great job!
>
> Instructions: please continue this theme, understanding our game, and produce word pairs that are relevant for an audience in Arabic
>
> 

Or

> do the same thing with 100 word pairs localized for Thailand/Thai. make sure any context notes are also localized for this language





Localize

https://github.com/ftp27/fastlane-plugin-translate_gpt?tab=readme-ov-file
