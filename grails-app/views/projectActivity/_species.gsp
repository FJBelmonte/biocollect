<r:require modules="admin, projectActivity"/>

<div id="pActivitySurvey">

        <!-- ko foreach: projectActivities -->

            <!-- ko if: current -->

            <div class="well">
                <div class="row-fluid">
                    <div class="span10 text-left">
                        <h2 class="strong">Step 5 of 7 - Set the range of species applicable for the survey</h2>
                    </div>
                    <div class="span2 text-right">
                        <g:render template="../projectActivity/status"/>
                    </div>
                </div>

                <g:render template="/projectActivity/warning"/>

                <g:render template="/projectActivity/unpublishWarning"/>

                <div class="row-fluid">
                    <div class="span12 text-left">
                        <p><g:message code="project.survey.species.description"/></p>
                    </div>
                </div>
                </br>
                <div class="row-fluid">
                    <div class="span3 text-left">
                      <label class="control-label"><g:message code="project.survey.species.fieldName"/></label>
                    </div>
                    <div class="span5 text-left">
                        <label class="control-label"><g:message code="project.survey.species.settings"/></label>
                    </div>
                    <div class="span4 text-left">
                        <label class="control-label"><g:message code="project.survey.species.displayAs"/> <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.displayAs"/>', content:'<g:message code="project.survey.species.displayAs.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                            <span class="right-padding"></span></label>
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="span3 text-left">
                        <label><b><g:message code="project.survey.species.defaultConfiguration"/></b>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.species.defaultConfiguration"/>', content:'<g:message code="project.survey.species.defaultConfiguration.content"/>'}">
                                <i class="icon-question-sign"></i>
                            </a>
                            <span class="right-padding"></span>
                        </label>

                    </div>
                    <div class="span5">
                        <span class="req-field">
                            <select data-validation-engine="validate[required]" data-bind="disable: true, options: $root.speciesOptions, optionsText:'name', optionsValue:'id', value: species.type, optionsCaption: 'Please select'" ></select>
                        </span>
                        <a target="_blank" class="btn btn-link" data-bind="click: species.showSpeciesConfiguration" ><small><g:message code="project.survey.species.configure"/></small></a>
                    </div>
                    <div class="span4 text-left">
                        <select data-bind="value: species.speciesDisplayFormat">
                            <option value="SCIENTIFICNAME(COMMONNAME)">Scientific name (Common name)</option>
                            <option value="COMMONNAME(SCIENTIFICNAME)">Common name (Scientific name)</option>
                            <option value="COMMONNAME">Common name</option>
                            <option value="SCIENTIFICNAME">Scientific name</option>
                        </select>

                    </div>
                </div>

            </div>

            <g:render template="/projectActivity/speciesFieldSettingsDialog"></g:render>

            <div class="row-fluid">

                <div class="span12">
                    <button class="btn-primary btn block btn-small"
                            data-bind="click: $parent.saveSpecies, disable: !transients.saveOrUnPublishAllowed()"><i class="icon-white  icon-hdd" ></i>  Save</button>
                    <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-form-tab'}"><i class="icon-white icon-chevron-left" ></i>Back</button>
                    <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-locations-tab'}">Next <i class="icon-white icon-chevron-right" ></i></button>
                </div>

            </div>

        <!-- /ko -->

        <!-- /ko -->
</div>


