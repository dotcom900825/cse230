> -- Pass in SinpleXML object in XML format
> -- Return a converted SimpleXML object in HTML format
> formatPlay :: SimpleXML -> SimpleXML
> formatPlay (Element name xs) = Element "html" [Element "body" (concatMap (playFormatXML 1) xs)]
>
>
> -- Function used to convert play from XML to HTML
> -- Parameters: Int       -> level of the tree for title formatting
> --             SimpleXML -> XML object before converting
> -- Return: [SimpleXML]   -> converted HTML objects in a list
> playFormatXML :: Int -> SimpleXML -> [SimpleXML]
> playFormatXML _ (PCDATA s) = [PCDATA s]
> playFormatXML n (Element name xs)
>   | name == "TITLE"     = titleFormatXML n xs
>   | name == "PERSONAE"  = listFormatXML 2 "Dramatis Personae" xs
>   | name == "ACT"       = concatMap (playFormatXML 2) xs
>   | name == "SCENE"     = concatMap (playFormatXML 3) xs
>   | name == "SPEECH"    = concatMap (playFormatXML 4) xs
>   | name == "SPEAKER"   = stringFormatXML True xs
>   | name == "LINE"      = stringFormatXML False xs
>   | otherwise           = []
>
>
> -- Generic Function to convert XML string into HTML format
> -- Parameters: Bool        -> boolean to indicate whether the string is bolded or not in HTML
> --             [SimpleXML] -> A PCDATA object in a list
> -- Return:     [SimpleXML] -> Converted HTML objects in a list
> stringFormatXML :: Bool -> [SimpleXML] -> [SimpleXML]
> stringFormatXML True xs = [Element "b" xs] ++ [PCDATA "<br/>"]
> stringFormatXML False [x] = x : [PCDATA "<br/>"] 
>
>
> -- Generic Function to convert XML list into HTML format
> -- Parameters: Int         -> size of the header that's >= 1
> --             String      -> title text
> --             [SimpleXML] -> A list of Element to convert to strings calling stringFormatXML
> -- Return:     [SimpleXML] -> Converted HTML string objects with title object in a list
> listFormatXML  :: Int -> String -> [SimpleXML]-> [SimpleXML]
> listFormatXML n title xs = (Element ("h"++show n) [PCDATA title]) : (concatMap (\(Element name x) -> stringFormatXML False x) xs)
>
>
> -- Generic Function to convert title into HTML format
> -- Parameters: Int         -> size of the header that's >= 1
> --             [SimpleXML] -> A PCDATA object in a list
> -- Return:     [SimpleXML] -> Converted HTML string object in a list
> titleFormatXML :: Int -> [SimpleXML] -> [SimpleXML]
> titleFormatXML n x = [Element ("h"++show n) x]
