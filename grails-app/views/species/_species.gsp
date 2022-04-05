<!-- This section is bound to a secondary KO viewModel. The following line prevents binding
         to the main viewModel. -->
<!-- ko stopBinding: true -->
<div class="row-fluid" id="species-container">
    <div class="row-fluid">
        <div class="clearfix">
            <h3 class="pull-left">Species of Interest</h3>
            %{--<g:link style="margin-bottom:10px;" action="species" id="${project.projectId}" class="btn pull-right title-edit">Edit Species Lists</a></g:link>--}%
        </div>
        <p class="well well-small">Species lists can be selected to be used by this project when species information is required to be supplied as a part of activity reporting.
            Lists are created and managed using the <a href="http://lists.ala.org.au">ALA Species List tool</a>.
            <g:if test="${project.listId}">
                <br><br>
                <g:set var="listUrl">${grailsApplication.config.lists.baseURL}/speciesListItem/list/${project.listId}</g:set>
                ALA Species List URL: <a href="${listUrl}" target="speciesList">${listUrl}</a>
            </g:if>
        </p>
    </div>
    <div class="row-fluid">
        <form class="form-horizontal" id="speciesListForm">
            <div class="control-group">
                <label class="control-label" for="speciesList">List of species<br>(one per line)</label>
                <div class="controls">
                    <textarea id="speciesList" rows="10" class="input-block-level validate[required]"></textarea>
                </div>
            </div>
            <div class="control-group hide">
                <label class="control-label" for="purpose">Used for</label>
                <div class="controls">
                    %{--<g:select name="purpose" from="${activityTypes}" noSelection="['':'']"/>--}%
                    <select id="purpose" name="purpose" class="validate[required] input-xlarge" >
                        <option value="">-- select an activity or assessment type --</option>
                        <g:each in="${activityTypes}" var="t" status="i">
                            <optgroup label="${t.name}">
                                <g:each in="${t.list}" var="opt">
                                    <option value="${opt.name}">${opt.name}</option>
                                </g:each>
                            </optgroup>
                        </g:each>
                    </select>
                </div>
            </div>
            <div class="control-group">
                <div class="controls">
                    <button id="submitSpeciesList" class="btn btn-primary">${project.listId ? "Update" : "Submit"}</button>
                    <g:img uri="${asset.assetPath(src:'spinner.gif')}" id="spinner1" class="hide spinner" alt="spinner icon"/>
                </div>
            </div>
        </form>
    </div><!-- /.row-fluid -->
</div>
<asset:script type="text/javascript">
    $(window).on('load',function(){
        // click event for submit species List
        $("#submitSpeciesList").on('click',function(e) {
            e.preventDefault();

            if ($('#speciesListForm').validationEngine('validate')) {
                var listItems = $.trim($('#speciesList').val()).replace(/(\r\n|\n|\r)/gm,",");
                var postData = {
                    listName: "${project.name.encodeAsJavaScript()}",
                    projectId: "${project.projectId}",
                    druid:  "${project.listId}",
                    listType: "LOCAL_LIST",
                    url: "${g.createLink(controller:'project',id:project.projectId, absolute:true)}",
                    description: "List generated by the Field Capture app",
                    listItems: listItems,
                    editors: "${admins}",
                    purpose: $('#purpose').val()
                }

                $.ajax({
                    type: 'POST',
                    contentType: 'application/json',
                    dataType: 'JSON',
                    url: "${g.createLink(controller: 'proxy', action: 'speciesListPost')}",
                    data: JSON.stringify(postData),
                    success: function(data) {
                        alert("Species list was saved.");
                        location.reload(true);
                     },
                    error: function(jqXHR, status, error) { alert("ERROR: " + jqXHR.responseText); }
                });
            }
        });

        var druid = "${project.listId}";
        if (druid) {
            // populate the textarea with saved list of species
            $.getJSON("${g.createLink(controller: 'proxy', action: 'speciesItemsForList')}?druid=" + druid, function(data) {
                if (data && data.length > 0) {
                    var speciesHtml = "";
                    $.each(data, function(i, el) {
                        speciesHtml += el.name + "\n";
                    });
                    $('#speciesList').val(speciesHtml);
                }
            }).fail(function(j,t,e){ alert(t + ":" + e);}).done();
        }

    });

</asset:script>
<!-- /ko -->