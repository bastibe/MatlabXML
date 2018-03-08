# MatlabXML

*Parses XML in pure Matlab*

Given an XML file as `test.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<content>
  <foo attr="bar"/>
</content>
```

You can read this file with

```matlab
>>> xml = MatlabXML('test.xml')

ans = 

  MatlabXMLElement with properties:

          Name: '#document#'
    Attributes: [2x1 containers.Map]
      Children: [1x1 MatlabXMLElement]

```

which will return a `MatlabXMLElement` with three properties:

- Name is the name of the element or document
- Attributes are the attributes of the element as `containers.Map`
- Children are the element's children as an array of `MatlabXMLElement`.

### Why?

Why would you use this instead of Matlab's built-in `xmlread`?

- `xmlread` is a horrible Java API that has no place in Matlab.
- `xmlread` is extremely slow for large XML files.
- `xmlread` will happily consume all your memory even if you max out your Java heap.

### Why not?

Because `MatlabXML` does not support all of XML.

- No support for `CDATA`.
- No support for text nodes.
- No support for DTD.
- No verification whatsoever.

### Examples:

```matlab
>>> xml.Attributes('version')

ans = 

    '1.0'
   
>>> xml.Children

ans = 

  MatlabXMLElement with properties:

          Name: 'content'
    Attributes: [0x1 containers.Map]
      Children: [1x1 MatlabXMLElement]


>>> xml.Children(1).Children(1)

ans = 

  MatlabXMLElement with properties:

          Name: 'foo'
    Attributes: [1x1 containers.Map]
      Children: [1x0 Double]


>>> xml.Children(1).Children(1).Attributes('attr')

ans = 

  'bar'


```
