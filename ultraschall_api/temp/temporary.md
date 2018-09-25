Let's face it, when editing items of a project in Reaper, you either click on the items or select them in a 2D-way, by drawing a boundary box around the items of your choice or using a time-selection.
What you do by that is selecting the items by time. What you also do is, selecting the items by track, as your boundary box may go over several tracks. Or you use a track-selection by clicking on the tracks you want.
In either way, you select them in a 2Dimensional way.
Not with Reaper's own API. Sure, you can somehow choose the MediaItems by track or by project, but you can't select by multiple tracks. And certainly not by a time-range.

This was annoying for me, so I wrote two functions(my favorite ones in this api, I have to admit ;) ) that address this: 
  [GetMediaItemsAtPosition](#GetMediaItemsAtPosition) and [GetAllMediaItemsBetween](#GetAllMediaItemsBetween).
  
Let's have a closer look at them.
[GetMediaItemsAtPosition](#GetMediaItemsAtPosition):

```            
    integer number_of_items, array MediaItemArray, array MediaItemStateChunkArray = ultraschall.GetMediaItemsAtPosition(number position, string trackstring)
```

This function gives you all items at position passed with parameter position and within the tracks given by parameter trackstring.
It returns the number of items, an array with all MediaItems and an array with all StateChunks of the MediaItems returned.
With this function, you can easily get the items from a certain position, without having to deal with looking into the MediaItem-objects for the correct time-position, or even have to care, where to get the corresponding tracks from an item.
This function does this for you.

But what, if you want to get the MediaItems inbetween a startingposition and an endposition?
For this, I wrote the function [GetAllMediaItemsBetween](#GetAllMediaItemsBetween):

```
     integer count, array MediaItemArray, array MediaItemStateChunkArray = 
                        ultraschall.GetAllMediaItemsBetween(number startposition, number endposition, string trackstring, boolean inside) 
```

which basically returns the same things, as GetMediaItemsAtPosition. The difference lies in the parameters.
You can pass a startposition and an endposition(which must be bigger than or equal startposition), [trackstrings](#Datatypes_trackstring), which is a string with all tracks, separated by commas and the parameter inside.
When you set inside to true, it will return only items that are completely within startposition and endposition. When setting inside to false, it will also return items, that are partially within start- and endposition, like items beginning before startposition or ending after endposition.

With these two functions, getting items is much, much easier than before.

In addition to them, I also added some more functions for getting MediaItems, namely:

   - [GetAllMediaItems](#GetAllMediaItems) - get all MediaItems from the project into a handy MediaItemArray, for further "mass-manipulation" of them.
   - [GetAllLockedItemsFromMediaItemArray](#GetAllLockedItemsFromMediaItemArray) - get all MediaItems that are locked, from a MediaItemArray
   - [GetAllMediaItemsFromTrack](#GetAllMediaItemsFromTrack) - get all MediaItems from a track, returned as MediaItemArray
   - [GetAllMediaItemsInTimeSelection](#GetAllMediaItemsInTimeSelection) - get all MediaItems in given tracks from the current time-selection

