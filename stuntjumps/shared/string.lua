-- Convert a string to kebab case
string.to_kebab_case = function(str)
    -- Convert to lowercase
    str = string.lower(str)
    
    -- Replace any non-alphanumeric characters (except spaces and hyphens) with nothing
    str = string.gsub(str, "[^%w%s%-]", "")
    
    -- Replace multiple spaces or hyphens with single hyphen
    str = string.gsub(str, "[-_%s]+", "-")
    
    -- Trim leading and trailing spaces/hyphens
    str = string.gsub(str, "^[%s%-]*(.-)[\%s%-]*$", "%1")
    
    return str
end