<xsl:stylesheet
        xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
        xmlns:dri="http://di.tamu.edu/DRI/1.0/"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        xmlns:xlink="http://www.w3.org/TR/xlink/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xalan="http://xml.apache.org/xalan"
        xmlns:encoder="xalan://java.net.URLEncoder"
        xmlns:stringescapeutils="org.apache.commons.lang3.StringEscapeUtils"
        xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
        exclude-result-prefixes="xalan encoder i18n dri mets dim  xlink xsl util stringescapeutils">

    <xsl:output indent="yes"/>

    <xsl:template match="dri:list/dri:list[@n='item-result-list']" mode="dsoList" priority="7">
        <xsl:apply-templates select="dri:head"/>
        <ul class="ds-artifact-list list-unstyled">
            <xsl:apply-templates select="*[not(name()='head')]" mode="dsoList"/>
        </ul>
    </xsl:template>

    <xsl:template name="itemSummaryList">
        <xsl:param name="handle"/>
        <xsl:param name="externalMetadataUrl"/>

        <xsl:variable name="metsDoc" select="document($externalMetadataUrl)"/>

        <li>
            <xsl:attribute name="class">
                <xsl:text>ds-artifact-item </xsl:text>
                <xsl:choose>
                    <xsl:when test="position() mod 2 = 0">even</xsl:when>
                    <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!--Generates thumbnails (if present)-->
            <!--
            <div class="col-sm-3 hidden-xs">
                <xsl:apply-templates select="$metsDoc/mets:METS/mets:fileSec" mode="artifact-preview">
                    <xsl:with-param name="href" select="concat($context-path, '/handle/', $handle)"/>
                </xsl:apply-templates>
            </div>
            -->

            <div class="artifact-description">
                <h4 class="artifact-title">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/@withdrawn">
                                    <xsl:value-of select="$metsDoc/mets:METS/@OBJEDIT"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($context-path, '/handle/', $handle)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="dri:list[@n=(concat($handle, ':dc.title'))]">
                                <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.title'))]/dri:item"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <span class="Z3988">
                        <xsl:attribute name="title">
                            <xsl:for-each select="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim">
                                <xsl:call-template name="renderCOinS"/>
                            </xsl:for-each>
                        </xsl:attribute>
                        <xsl:text>&#160;</xsl:text>
                    </span>
                </h4>
                <div class="artifact-info">
                    <span class="author h4">    <small>
                        <xsl:choose>
                            <xsl:when test="dri:list[@n=(concat($handle, ':dc.contributor.author'))]">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.contributor.author'))]/dri:item">
                                    <xsl:variable name="author">
                                        <xsl:apply-templates select="."/>
                                    </xsl:variable>
                                    <span>
                                        <!--Check authority in the mets document-->
                                        <xsl:if test="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='contributor' and @qualifier='author' and . = $author]/@authority">
                                            <xsl:attribute name="class">
                                                <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                            </xsl:attribute>
                                        </xsl:if>
                                        <xsl:apply-templates select="."/>
                                    </span>

                                    <xsl:if test="count(following-sibling::dri:item) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dri:list[@n=(concat($handle, ':dc.creator'))]">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.creator'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="count(following-sibling::dri:item) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dri:list[@n=(concat($handle, ':dc.contributor'))]">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.contributor'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="count(following-sibling::dri:item) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </small></span>
                    <xsl:text> </xsl:text>
                    <xsl:if test="dri:list[@n=(concat($handle, ':dc.date.issued'))]">
                        <span class="publisher-date h4">   <small>
                            <xsl:text>(</xsl:text>
                            <xsl:if test="dri:list[@n=(concat($handle, ':dc.publisher'))]">
                                <span class="publisher">
                                    <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.publisher'))]/dri:item"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of
                                        select="substring(dri:list[@n=(concat($handle, ':dc.date.issued'))]/dri:item,1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </small></span>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item/dri:hi">
                            <div class="abstract">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:text>...</xsl:text>
                                    <br/>
                                </xsl:for-each>

                            </div>
                        </xsl:when>
                        <xsl:when test="dri:list[@n=(concat($handle, ':fulltext'))]">
                            <div class="abstract">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':fulltext'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:text>...</xsl:text>
                                    <br/>
                                </xsl:for-each>
                            </div>
                        </xsl:when>
                        <xsl:when test="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item">
                            <div class="abstract">
                                <xsl:value-of select="util:shortenString(dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item[1], 220, 10)"/>
                            </div>
                        </xsl:when>
                    </xsl:choose>
                </div>
            </div>
        </li>
    </xsl:template>

</xsl:stylesheet>