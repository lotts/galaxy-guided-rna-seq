# Galaxy - de.STAIR
# git clone --recursive https://github.com/destairdenbi/galaxy-guided-rna-seq.git
# cd galaxy-guided-rna-seq
# docker build -t destairdenbi/galaxy-guided-rna-seq:17.05 .
# docker run -d -p 8080:80 -v ~/galaxy-guided-rna-seq_DB:/export destairdenbi/galaxy-guided-rna-seq:17.05
# troubleshoot: --net host

FROM bgruening/galaxy-stable:17.05

MAINTAINER de.STAIR destair@leibniz-fli.de

ENV GALAXY_CONFIG_BRAND="RNA-Seq" \
    GALAXY_CONFIG_CONDA_AUTO_INSTALL=True \
    GALAXY_CONFIG_CONDA_AUTO_INIT=True

COPY tools.yaml $GALAXY_ROOT/tools.yaml
COPY workflows /tmp/workflows
COPY guided_tours /tmp/guided_tours
COPY webhooks /tmp/webhooks
        
RUN install-tools $GALAXY_ROOT/tools.yaml && \
    $GALAXY_CONDA_PREFIX/bin/conda clean --tarballs --yes > /dev/null && \
    rm -rf /export/galaxy-central/

RUN startup_lite && \
    galaxy-wait && \
    workflow-install --workflow_path /tmp/workflows/ -g http://localhost:8080 -u $GALAXY_DEFAULT_ADMIN_USER -p $GALAXY_DEFAULT_ADMIN_PASSWORD && \
    rm -rf /tmp/workflows

RUN echo "destair is coming" > $GALAXY_CONFIG_WELCOME_URL && \
    mv /tmp/webhooks/switchtour $GALAXY_ROOT/config/plugins/webhooks && \
    rm -rf /tmp/webhooks && \
    mv /tmp/guided_tours/*yaml $GALAXY_ROOT/config/plugins/tours/ && \
    rm -rf /tmp/guided_tours
 
