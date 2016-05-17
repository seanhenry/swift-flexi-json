import FlexiJSON
/*:
 # FlexiJSON
 ## Creation
 Create a flexible JSON object from dictionary, array, string and other JSON fragments.
*/
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
var json = FlexiJSON(dictionary: dictionary)
/*:
 ## Browse
 Use subscript to navigate through your JSON and access JSON fragments from the properties.
 */
json["item"]["id"].int
json["item"]["name"].string
json["item"]["for_sale"].bool
json["item"]["price"].double
json["item"]["related_items"][0]["id"].int
json["item"].dictionary
json["item"]["related_items"].array
/*:
 ## Mutability
 Change the JSON by assigning JSON fragments.
 */
json["item"]["for_sale"] = true
json["item"]["for_sale"].bool
//: Create new fields.
json["new"] = "field"
json["new"].string
//: Change the fragment type.
json["item"]["for_sale"] = nil
json["item"]["for_sale"].null
/*:
 ## Build
 Build a JSON structure from scratch.
 */
var builtJSON = FlexiJSON(dictionary: [:])
builtJSON["item"] = [:]
builtJSON["item"]["id"] = 123456789
builtJSON["item"]["name"] = "FlexiJSON"
builtJSON["item"]["for_sale"] = nil
builtJSON["item"]["price"] = 9.99
builtJSON["item"]["related_items"] = [["id": 987654321], ["id": 321456987]]
builtJSON["new"] = "field"
builtJSON.dictionary
/*:
 ## Compare
 FlexiJSON conforms to the Equatable protocol.
 */
builtJSON == json
builtJSON["extra"] = false
builtJSON == json
/*:
 ## Loop
 Iterate through arrays using `for in` syntax.
 */
for var item in json["item"]["related_items"] {
    item["id"].int
}
