// Parses a URL into its components
// real httpParseUrl(string url)

// Return value is a ds_map containing keys for the different URL parts: (or -1 on failure)
// "url" - the URL which was passed in
// "scheme" - the URL scheme (e.g. "http")
// "host" - the hostname (e.g. "example.com" or "127.0.0.1")
// "port" - the port (e.g. 8000) - this is a real, unlike the others
// "fullhost" - the host and possibly port from the url (e.g. "example.com:8000")
// "path" - the path (e.g. "/" or "/index.html")
// "query" - the query string (e.g. "a=b&c=3")
// Parts which are not included will not be in the map
// e.g. http://example.com will not have the "port", "path" or "query" keys

// This will *only* work properly for URLs of format:
// scheme://host[:port][/path[?query]]
// where [] denotes an optional component

var url;
url = argument0;

var map, state;
map = ds_map_create();
ds_map_add(map, 'url', url);
state = 0;

while (string_length(url) > 0)
{
    switch (state)
    {
    // before scheme
    case 0:
        var colonPos;
        // Find colon for end of scheme
        colonPos = string_pos(':', url);
        // No colon - bad URL
        if (colonPos == 0)
            return -1;
        ds_map_add(map, 'scheme', string_copy(url, 1, colonPos - 1));
        url = string_copy(url, colonPos + 1, string_length(url) - colonPos);
        state = 1;
        break;
    // before double slash
    case 1:
        // remove slashes (yes this will screw up file:// but who cares)
        while (string_char_at(url, 1) == '/')
            url = string_copy(url, 2, string_length(url) - 1);
        state = 2;
        break;
    // before hostname
    case 2:
        var slashPos, colonPos;
        // Find slash for beginning of path
        slashPos = string_pos('/', url);
        // No slash ahead - http://host format with no ending slash
        if (slashPos == 0)
        {
            // Find : for beginning of port
            colonPos = string_pos(':', url);
            ds_map_add(map, 'fullhost', url);
        }
        else
        {
            // Find : for beginning of port prior to /
            colonPos = string_pos(':', string_copy(url, 1, slashPos - 1));
            ds_map_add(map, 'fullhost', string_copy(url, 1, slashPos - 1));
        }
        // No colon - no port
        if (colonPos == 0)
        {
            // There was no slash
            if (slashPos == 0)
            {
                ds_map_add(map, 'host', url);
                return map;
            }
            // There was a slash
            else
            {
                ds_map_add(map, 'host', string_copy(url, 1, slashPos - 1));
                url = string_copy(url, slashPos, string_length(url) - slashPos + 1);
            }
        }
        // There's a colon - port specified
        else
        {
            // There was no slash
            if (slashPos == 0)
            {
                ds_map_add(map, 'host', string_copy(url, 1, colonPos - 1));
                ds_map_add(map, 'port', real(string_copy(url, colonPos + 1, string_length(url) - colonPos)));
                return map;
            }
            // There was a slash
            else
            {
                ds_map_add(map, 'host', string_copy(url, 1, colonPos - 1));
                url = string_copy(url, colonPos + 1, string_length(url) - colonPos);
                slashPos = string_pos('/', url);
                ds_map_add(map, 'port', real(string_copy(url, 1, slashPos - 1)));
                url = string_copy(url, slashPos, string_length(url) - slashPos + 1); 
            }
        }
        state = 3;
        break;
    // before path
    case 3:
        var queryPos;
        queryPos = string_pos('?', url);
        // There's no ? - no query
        if (queryPos == 0)
        {
            ds_map_add(map, 'path', url);
            return map;
        }
        else
        {
            ds_map_add(map, 'path', string_copy(url, 1, queryPos - 1));
            ds_map_add(map, 'query', string_copy(url, queryPos + 1, string_length(url) - queryPos));
            return map;
        }
        break;
    }
}

return -1;
