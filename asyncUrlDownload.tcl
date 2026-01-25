package require http
package require tls
http::register https 443 ::tls::socket

set urls {
    https://www.google.com
    https://www.wikipedia.org
    https://www.facebook.com
    https://www.bing.com
}

# Counter to track completed downloads
set pending [llength $urls]


proc handle_response {token} {
    global pending

    set url   [http::ncode $token]
    set status [http::status $token]
    set data  [http::data $token]

    if {$status eq "ok"} {
        puts "Downloaded $url ([string length $data] bytes)"
    } else {
        puts "Failed to download $url (status: $status)"
    }

    # Clean up
    http::cleanup $token

    # Decrement pending count
    incr pending -1

    # Exit event loop when all downloads finish
    if {$pending == 0} {
        puts "All downloads completed."
        set ::done 1
    }
}

# Start all downloads asynchronously
foreach url $urls {
    http::geturl $url -command handle_response
}

# Enter event loop
vwait ::done
