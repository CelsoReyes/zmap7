<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="/html/body"/>
  </xsl:template>

  <xsl:template match="body">
      <xsl:value-of select="p"/>
       <xsl:text>
</xsl:text>
  </xsl:template>

</xsl:stylesheet>
