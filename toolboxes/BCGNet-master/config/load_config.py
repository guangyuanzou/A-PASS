from pathlib import Path
import logging
import pprint

import yaml
from easydict import EasyDict as edict


def _init_empty_config_struct():
    """
    Initializes the empty configuration structure with all fields populated with None. This structure is subsequently
    populated with parameters read from the yaml file

    :return: an empty configuration structure
    """

    cfg = edict()

    cfg.d_root = None  # path to the root of the package
    cfg.d_data = None  # path to the directory containing all data
    cfg.d_model = None  # path to the directory to save the model/load trained models
    cfg.d_output = None  # path to the directory to save cleaned data
    cfg.d_eval = None  # (optional) path to the directory holding dataset for evaluating the method
    cfg.str_eval = None  # string describing the evaluation method

    cfg.new_fs = None  # desired sampling rate at which the model is trained
    cfg.len_epoch = None  # length of each epoch in seconds
    cfg.mad_threshold = None  # n times the median absolute deviation to be used for outlier rejection
    cfg.per_training = None  # percentage of training set epochs
    cfg.per_valid = None  # percentage of validation set epochs
    cfg.per_test = None  # percentage of test set epochs

    cfg.num_epochs = None  # maximum number of epochs used in training
    cfg.lr = None  # learning rate for training the model
    cfg.batch_size = None  # batch size for training the model
    cfg.es_patience = None  # number of epochs over which improvement is evaluated for early stopping
    cfg.es_min_delta = None  # minimum change between loss values from epoch to epoch to be considered improvement

    cfg.cutoff_low_delta = None
    cfg.cutoff_high_delta = None
    cfg.cutoff_low_theta = None
    cfg.cutoff_high_theta = None
    cfg.cutoff_low_alpha = None
    cfg.cutoff_high_alpha = None

    return cfg


def get_config(filename="default_config.yaml"):
    """
    Loads the configuration from the yaml file in the same directory

    :param filename: absolute path to the yaml file

    :return: fully loaded configuration file
    """
    cfg_struct = _init_empty_config_struct()

    return _config_from_file(filename, cfg_struct)


def _merge_a_into_b(a, b):
    """
    Merge config dictionary a into config dictionary b, clobbering the
    options in b whenever they are also specified in a.
    """
    if type(a) is not edict:
        return

    for k, v in a.items():
        # a must specify keys that are in b
        # if k not in b:
        #    raise KeyError('{} is not a valid config key'.format(k))

        # recursively merge dicts
        if type(v) is edict:
            try:
                _merge_a_into_b(a[k], b[k])
            except:
                print("Error under config key: {}".format(k))
                raise
        else:
            b[k] = v


def _config_from_file(filename, cfg):
    """
    Load a config from file filename and merge it into the default options.
    """
    with open(filename, "r") as f:
        yaml_cfg = edict(yaml.load(f, Loader=yaml.SafeLoader))

    _merge_a_into_b(yaml_cfg, cfg)

    cfg.d_data = Path(cfg.d_data)
    cfg.d_model = Path(cfg.d_model)
    cfg.d_output = Path(cfg.d_output)
    if cfg.d_eval is not None:
        cfg.d_eval = Path(cfg.d_eval)

    logging.info("Config:\n" + pprint.pformat(cfg))
    return cfg


if __name__ == "__main__":
    print(get_config())