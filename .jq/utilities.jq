# utilities.jq - Common jq utilities

module "utilities";

# Converts an array of simple objects (Objects with only scalar values) to a
# the format passed in the format parameter e.g. @csv, @tsv, @sh
def array_of_simple_objects_to_format(format):
    # Get the data sources' keys without any sorting into $keys
    (
        .[0]
        | keys_unsorted
    ) as $keys
    # For every key map the value into a scalar corresponding to the same
    # position in another nested array
    | $keys, map( [ .[ $keys[] ] ] )[]
    # Pass both keys and values to the formatting function
    | format
;
