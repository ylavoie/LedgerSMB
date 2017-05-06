define([
    "dojo/store/JsonRest", "dojo/query", "dojo/store/Memory", "dojo/store/Observable",
    "dijit/Tree", "dijit/tree/ObjectStoreModel", "dijit/tree/dndSource", "dojo/domReady!"
], function(JsonRest, query, Memory, Observable,
    Tree, ObjectStoreModel, dndSource){

    // set up the store to get the tree data, plus define the method
    // to query the children of a node
    var memoryStore = new JsonRest({
        target:      "menu.pl?action=menuitems_json&",
        getChildren: function(object){
            // object may just be stub object, so get the full object first and then return it's
            // list of children
            return this.get(object.id).then(function(fullObject){
                return fullObject.children;
            });
        }
    });
    // give store Observable interface so Tree can track updates
    memoryStore = new Observable(memoryStore);

    // create model to interface Tree to store
    var model = new ObjectStoreModel({
        store: memoryStore,
        // query to get root node
        //query: {id: new RegExp('.*')}
    });

    tree = new Tree({
        model: model,
        dndController: dndSource,
        showRoot: false,
        openOnClick: true
    }, "menuTree"); // make sure you have a target HTML element with this id
    tree.startup();
    return tree;
});
