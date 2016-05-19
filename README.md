# FlexiJSON
Another Swift JSON library. Effortlessly create, navigate, mutate, compare, and export your JSON.
## Creation
Create a flexible JSON object from `dictionary`, `array`, `data`, `string` and other JSON fragments.  

```
var json = FlexiJSON(jsonString: "{ \"simple\": \"json\" }")  
let dictionary = [  
    "item": [  
        "id": 123456789,  
        "name": "FlexiJSON",  
        "for_sale": false,  
        "price": 9.99,  
        "related_items": [  
            ["id": 987654321],  
            ["id": 321456987]  
        ],  
    ]  
]  
json = FlexiJSON(dictionary: dictionary)  
```

## Browse
Use subscript to navigate through your JSON and access JSON fragments from the properties.  

```
json["item"]["id"].int
json["item"]["name"].string
json["item"]["for_sale"].bool
json["item"]["price"].double
json["item"]["related_items"][0]["id"].int
json["item"].dictionary
json["item"]["related_items"].array
```

## Mutability
Change values.

```
json["item"]["for_sale"] = true
json["item"]["for_sale"].bool
```

Create new fields.

```
json["new"] = "field"
json["new"].string
```

Change the type.

```
json["item"]["for_sale"] = nil
json["item"]["for_sale"].null
```

## Build
Build a JSON structure from scratch.

```
var builtJSON = FlexiJSON(dictionary: [:])
builtJSON["item"] = [:]
builtJSON["item"]["id"] = 123456789
builtJSON["item"]["name"] = "FlexiJSON"
builtJSON["item"]["for_sale"] = nil
builtJSON["item"]["price"] = 9.99
builtJSON["item"]["related_items"] = [["id": 987654321], ["id": 321456987]]
builtJSON["new"] = "field"
builtJSON.dictionary
```

## Equatability
`FlexiJSON` conforms to the `Equatable` protocol.

```
builtJSON == json
builtJSON["extra"] = false
builtJSON == json
```

## Loop
Iterate through arrays using `for in` syntax.

```
for var item in json["item"]["related_items"] {
    item["id"].int
}
```

## Output
After manipulating your JSON you can export it as a `string` or `data`.

```
builtJSON.jsonString
builtJSON["item"].data
```
