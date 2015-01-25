> formatPlay :: SimpleXML -> SimpleXML
> formatPlay (Element name xs) = Element "html" [Element "body" (concatMap (levelFormatXML 1) xs)]
>
>
> levelFormatXML :: Int -> SimpleXML -> [SimpleXML]
> levelFormatXML _ (PCDATA s) = [PCDATA s]
> levelFormatXML n (Element name xs)
>   | name == "TITLE"     = titleFormatXML n xs
>   | name == "PERSONAE"  = (Element "h2" [PCDATA "Dramatis Personae"]) : concatMap (\(Element name x) -> (x ++ [PCDATA "<br/>"])) xs
>   | name == "ACT"       = concatMap (levelFormatXML 2) xs
>   | name == "SCENE"     = concatMap (levelFormatXML 3) xs
>   | name == "SPEECH"    = concatMap (levelFormatXML 4) xs
>   | name == "SPEAKER"   = [Element "b" xs] ++ [PCDATA "<br/>"]
>   | name == "LINE"      = concatMap (\x -> (x:[PCDATA "<br/>"])) xs
>   | otherwise           = [Element name xs]
>
>
> titleFormatXML :: Int -> [SimpleXML] -> [SimpleXML]
> titleFormatXML n (x:xs)
>   | n == 1     = [Element "h1" $ levelFormatXML n x]
>   | n == 2     = [Element "h2" $ levelFormatXML n x]
>   | n == 3     = [Element "h3" $ levelFormatXML n x]
>   | otherwise  = [Element "h4" $ levelFormatXML n x]