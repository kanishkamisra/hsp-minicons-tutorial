## Federmeier and Kutas (1999) stimuli cleanup

Original paper: https://www.sciencedirect.com/science/article/pii/S0749596X99926608

**Massive shoutout to Kara Federmeier for sharing the data with me!**



The original data (without the cloze constraint) can be found in `data/concatstim`, which is a text file that looks like this:

```
Ann wanted to treat her foreign guests to an all-American pie.
She went out in the back yard and picked some apples.

Ann wanted to treat her foreign guests to an all-American pie.
She went out in the back yard and picked some oranges.

Ann wanted to treat her foreign guests to an all-American pie.
She went out in the back yard and picked some carrots.
```

I then got the cloze constraint measures as a separate string, that looked like this:

```
2080      17           tulips    

2976      25.4       tank      

2551      28.6       triceratops         

2539      32.1       pterodactyl
```

Here, I interpreted these values to be `cloze-trial, constraint, expected_word` Thankfully, the expected word is unique throughout the string and that each prefix is associated with one word that was most expected. I finally ended up cleaning and joining both these files/strings, giving us the final stimuli which looked something like this (random sample):

| item | prefix                                                                                                                         | expected       | within_category | between_category | cloze_expected     | constraint |
|------|--------------------------------------------------------------------------------------------------------------------------------|----------------|-----------------|------------------|--------------------|------------|
| 53   | Maria said she would only eat the kind with small curds. She's not picky in general, but apparantly she's particular about her | cottage cheese | Swiss cheese    | hamburgers       | 0.717 | low        |
| 96   | For Christmas, her grandparents sent her a big box of oranges. They'd done that every year since they moved to                 | Florida        | Texas           | China            | 0.814 | high       |
| 16   | Grandpa insists that his circulation is getting poorer. Yet the doctor says that there's nothing wrong with his                | heart          | lungs           | arm              | 0.458              | low        |