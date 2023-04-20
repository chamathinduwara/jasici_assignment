import {*} with "./graph.jac";

walker create_familytree {
    // creates a familytree from a json file
    has data_file = "examples/coursework-series-uom/2_jaseci_quickstart/2.2/start/familytree.json";
    has famly_members = [];

    root {
        families = file.load_json(data_file)["families"];
        for family in families {
            spawn here ++> node::family_root(
                id = family["uid"],
                family_name = family["family_name"]
            );
        }
        take-->node::family_root;
    }

    family_root {
        family_id = here.id;
        members = file.load_json(data_file)["members"];
        filtered_members = [];
        for member in members {
            if (member["family_id"] == family_id) {
                filtered_members.list::append(member);
            }
        }
        for member in filtered_members {
            family_member = spawn here +[member]+> node::person(
                id = member["uid"],
                family_id = member["family_id"],
                name = member["name"],
                date_of_birth = member["date_of_birth"],
                profession = member["profession"],
                gender = member["gender"],
                deceased = member["deceased"],
                parents = member["parents"],
                children = member["children"],
                spouse = member["spouse"]
            );
            famly_members.list::append(family_member);
        }
    }

    with exit {
        for member_1 in famly_members {
            for member_2 in famly_members {
                if (member_1.id  == member_2.id): continue;
                if (member_1.spouse == member_2.id and member_2.spouse == member_1.id) {
                    member_1 +[married]+> member_2;
                }
                if (member_1.id in member_2.children): member_1 +[child]+> member_2;
            }
        }
    }
}

walker find_coming_birthday {
    // returns the upcoming birthdays of the family
    has max_return = 5;
    has anchor birthday_order = [];

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (!here.deceased) {
            here::get_days_to_birthday;
            here::get_age;
            birthday_order.l::append([here.days_to_birthday, here.age, here.name]);
        }
    }
    with exit {
        birthday_order = std.sort_by_col(birthday_order, 0);
        birthday_order = birthday_order[0:max_return];
        std.out(birthday_order);
        report birthday_order;
    }
}


walker find_profession_count {
    // returns people count in each profession
    has data_file = "examples/coursework-series-uom/2_jaseci_quickstart/2.2/start/familytree.json";
    has anchor same_profession_names = [];

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        same_profession_names = [];
        members = file.load_json(data_file)["members"];

        for member in members {
            if (here.id == member["uid"]): continue;
            if (here.profession == member["profession"]) {
                same_profession_names.list::append(member["name"]);
            }
        }
        here.profession_list = same_profession_names;
    }

    with exit {

    }
}


walker change_values {
    // returns people count in each profession
    has data_file = "examples/coursework-series-uom/2_jaseci_quickstart/2.2/start/familytree.json";
    has anchor change_list = [];
    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        members = file.load_json(data_file)["members"];

        for member in members {
            if (here.id == member["uid"]) {
                if (member["name"] != ""){
                    here.name = member["name"];
                    change_list.list::append([here.id,here.name]);
                }
                if (member["date_of_birth"] != ""){
                    here.date_of_birth = member["date_of_birth"];
                    change_list.list::append([here.id,here.date_of_birth]);
                }
                if (member["profession"] != ""){
                    here.profession = member["profession"];
                    change_list.list::append([here.id,here.profession]);
                }
                if (member["gender"] != ""){
                    here.gender = member["gender"];
                    change_list.list::append([here.id,here.gender]);
                }
                
            }
        }
    }

    with exit {
        std.out(change_list);
        report change_list;
    }
}




// walker find_profession_count {
//     // returns people count in each profession

//     has max_return = 10;
//     has anchor same_profession_names = [];

//     root: take-->node::family_root;
//     family_root: take-->node::person;
//     person {
//         per_profession = here.profession;
//         for member in famly_members {
//             if (member.id == here.id): continue;
//             if (per_profession == member.profession) {
//                 same_profession_names.list::append(member.name);
//             }
//         }
//         here::pro_list = same_profession_names;
//     }

//     with exit {
//         std.out(same_profession_names);
//         report same_profession_names;
//     }
// }