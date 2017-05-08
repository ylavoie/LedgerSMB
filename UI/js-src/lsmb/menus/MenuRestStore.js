define([
    "dojo/store/JsonRest", "dojo/store/Observable",
//    "dojo/store/Memory", "dojo/store/Cache",
    "dijit/Tree", "dijit/tree/ObjectStoreModel",
    "dijit/tree/dndSource",
    "dijit/Menu", "dojo/domReady!"
], function(JsonRest, Observable,
//    Memory, Cache,
    Tree, ObjectStoreModel,
    dndSource,
    Menu
){
    // set up the store to get the tree data, plus define the method
    // to query the children of a node
    var restStore = new JsonRest({
        target:      "menu.pl?action=menuitems_json",
    });
    var store;
//    var memoryStore = new Memory();
//    store = new Cache(restStore, memoryStore);
    // give store Observable interface so Tree can track updates
    store = new Observable(restStore);

    // create model to interface Tree to store
    var model = new ObjectStoreModel({
        store: store,
        // query to get root node
        query: {id: '0'},
        // Utility routines
        mayHaveChildren: function(object){
            // if true, we might be missing the data, false and nothing should be done
            return "children" in object;
        },
        getChildren: function(object, onComplete, onError){
            // this.get calls 'mayHaveChildren' and if this returns true, it will load whats needed, overwriting the 'true' into '{ item }'
            this.store.query({parent_id: object.id}).then(function(fullObject){
                // copy to the original object so it has the children array as well.
                object.children = fullObject;
                // now that full object, we should have an array of children
                onComplete(fullObject);
            }, function(error){
                // an error occurred, log it, and indicate no children
                console.error(error);
                onComplete([]);
            });
        },
        getRoot: function(onItem, onError){
            // get the root object, we will do a get() and callback the result
            this.store.query({id: '0'}).then(onItem, onError);
        },
        getLabel: function(object){
            // just get the name (note some models makes use of 'labelAttr' as opposed to simply returning the key 'name')
            return object.label;
        }
    });

    var tree = new Tree({
        model: model,
        dndController: dndSource,
//        showRoot: false,
//        openOnClick: true
    }, 'menuTree'); // make sure you have a target HTML element with this id
    console.dir(tree);

    var menu = new Menu({
        targetNodeIds: ['menuTree'],
//        selector: "rowNode"
    });
    console.dir(menu);
    return menu;
});
