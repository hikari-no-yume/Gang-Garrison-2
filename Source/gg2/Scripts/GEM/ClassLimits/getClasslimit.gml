// First checks whether the suggested class is acceptable, and if it isn't returns a random class
// argument0 == the team
// argument1 == the wanted class

if iterateTeammates(argument0, argument1) < global.classlimits[argument1]
{
    return argument1// You're allowed to get the class you wished for.
}

// Uh-oh, too many have that class. Randomly select another.

var class, classlist;

classlist = ds_list_create()

for (a=0; a<9; a+=1) ds_list_add(classlist, a)// Add all classes except quote to the list.

while !ds_list_empty(classlist)
{
    class = ds_list_find_value(classlist, random(ds_list_size(classlist)))// Get a random class
    if iterateTeammates(argument0, class) < global.classlimits[class]
    {
        return class
    }
}

if global.isHost
{
    show_message("The classlimits were set too low on this server,#please set them to be higher than the maximum number of players.")
    return argument1
}