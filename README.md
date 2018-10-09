# OpenStructure docker container

This container includes OpenStructure 1.8.0 - http://www.openstructure.org/

## Using the container with docker

### Executing the OpenStructure binary with Docker

   `$> docker run -ti --rm pescobar/openstructure -h`

### Running OpenStructure interactive session with Docker
   
```
   $> docker run -ti --rm pescobar/openstructure -i 

   ost> import ost

```

### Interactive shell inside the container with Docker (to browse the contents)

   `$> docker run -ti --rm --entrypoint /bin/bash pescobar/openstructure`


## Using the container with Singularity (recommended for HPC clusters)

### Downloading the container with Singularity

   `$> singularity pull -n "OpenStructure-1.8.img" docker://pescobar/openstructure:latest`

### Executing the OpenStructure binary with singularity

   `$> singularity exec OpenStructure-1.8.img ost -h`

### Running OpenStructure interactive session with Singularity

```
    $> singularity exec OpenStructure-1.8.img ost -i

    ost> import ost
```

### Interactive shell inside the container with singularity (to browse the contents)

   `$> singularity shell OpenStructure-1.8.img`

By default you would open the Singularity container with RO permissions. To get a shell with
write permission use the `-w` flag:

   `$> singularity shell -w OpenStructure-1.8.img`

